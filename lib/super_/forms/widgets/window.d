module super_.forms.widgets.window;

import erupted;
import std.algorithm;
import std.typecons;
import super_.forms;
import super_.forms.drawing;
import tinyevent;

package(super_.forms) shared struct DrawPayload {
    VkSwapchainKHR swapchain = VK_NULL_HANDLE;
    VkSurfaceCapabilitiesKHR capabilities;

    VkCommandPool commandPool;
    VkCommandBuffer[] commandBuffers;
    VkImage[] images;

    VkFence[] fences;
    VkSemaphore[] readySemaphores;
    VkSemaphore[] doneSemaphores;

    VkQueue presentQueue;
    uint presentQueueIndex;

    uint imageCount;
    uint currentImage = 0;

    ulong renderLoop = ulong.max;
}

/++
 + Represents a window, and abstracts the backend on top of a Widget.
 +/
@safe class Window: Container!Widget {
    private shared NativeWindow nativeWindow;

    /++
     + Return window title.
     +/
    @property string title() {
        return nativeWindow.title;
    }

    /++
     + Set window title.
     +/
    @property void title(string val) {
        nativeWindow.title = val;
    }

    /++
     + Get window size.
     +/
    @property Tuple!(uint, uint) size() @trusted {
        return nativeWindow.size;
    }

    /++
     + Set window size.
     +/
    @property void size(uint width, uint height) @trusted {
        nativeWindow.size(width, height);
    }

    /++
     + Get window position.
     +/
    @property Tuple!(int, int) position() @trusted {
        return nativeWindow.position;
    }

    /++
     + Set window position. [undefined behaviour: moving a hidden window]
     +/
    @property void position(int x, int y) @trusted {
        nativeWindow.position(x, y);
    }

    /++
     + Event triggered when close button is pressed.
     +/
    ref shared(Event!()) closed() {
        return nativeWindow.closed;
    }

    package(super_.forms) shared(DrawPayload) drawPayload;

    private super_.forms.drawing.Surface vkvgSurface;

    ~this() @trusted {
        if (vkvgSurface)
            destroy(vkvgSurface);

        if (drawPayload.renderLoop != ulong.max)
            Application.instance.unregisterLoop(drawPayload.renderLoop);

        nativeWindow.hide();

        for (int i = 0; i < drawPayload.imageCount; i++) {
            Application.instance.backendContext.device.vkDestroySemaphore(cast(VkSemaphore) drawPayload.readySemaphores[i], null);
            Application.instance.backendContext.device.vkDestroySemaphore(cast(VkSemaphore) drawPayload.doneSemaphores[i], null);
            Application.instance.backendContext.device.vkDestroyFence(cast(VkFence) drawPayload.fences[i], null);
        }

        Application.instance.backendContext.device.vkDestroyCommandPool(cast(VkCommandPool) drawPayload.commandPool, null);
        Application.instance.backendContext.device.vkDestroySwapchainKHR(cast(VkSwapchainKHR) drawPayload.swapchain, null);
        destroy(nativeWindow);
    }

    this() @trusted {
        nativeWindow = Application.instance.backend.createWindow(this);
        this.size(800, 600);

        uint queueCount;
        vkGetPhysicalDeviceQueueFamilyProperties(Application.instance.backendContext.physicalDevice, &queueCount, null);

        VkQueueFamilyProperties[] props = new VkQueueFamilyProperties[](queueCount);
        vkGetPhysicalDeviceQueueFamilyProperties(Application.instance.backendContext.physicalDevice, &queueCount, props.ptr);

        drawPayload.presentQueueIndex = queueCount;
        for (uint i = 0; i < queueCount; i++) {
            if (nativeWindow.canPresent(
                Application.instance.backendContext.physicalDevice,
                i
            )) {
                drawPayload.presentQueueIndex = i;
                break;
            }
        }
        if (drawPayload.presentQueueIndex == queueCount) {
            throw new VulkanException!vkGetPhysicalDeviceQueueFamilyProperties();
        }

        vkGetDeviceQueue(
            Application.instance.backendContext.device,
            cast(uint) drawPayload.presentQueueIndex,
            0,
            cast(VkQueue*) &drawPayload.presentQueue,
        );

        VkImageLayout[] imageLayouts = new VkImageLayout[](drawPayload.imageCount);

        createSwapchain();

        drawPayload.renderLoop = Application.instance.registerLoop(() shared {
            with (drawPayload) {
                Application.instance.backendContext.device.vkWaitForFences(1, cast(VkFence*) &fences[currentImage], VK_TRUE, ulong.max);

                uint imageIndex;
                VkResult result = Application.instance.backendContext.device.vkAcquireNextImageKHR(
                    cast(VkSwapchainKHR) swapchain,
                    ulong.max,
                    cast(VkSemaphore) readySemaphores[currentImage],
                    VK_NULL_HANDLE,
                    &imageIndex
                );

                if (result == VK_ERROR_OUT_OF_DATE_KHR) {
                    createSwapchain();
                    return;
                } else if (result != VK_SUCCESS && result != VK_SUBOPTIMAL_KHR) {
                    throw new VulkanException!vkAcquireNextImageKHR();
                }

                uint width = min(
                max(drawPayload.capabilities.currentExtent.width, drawPayload.capabilities.minImageExtent.width),
                drawPayload.capabilities.maxImageExtent.width
                );

                uint height = min(
                max(drawPayload.capabilities.currentExtent.height, drawPayload.capabilities.minImageExtent.height),
                drawPayload.capabilities.maxImageExtent.height
                );

                super_.forms.drawing.Context ctx = new super_.forms.drawing.Context(vkvgSurface);
                ctx.setSourceRgb(0, 50, 0);
                ctx.paint();
                destroy(ctx);

                VkSubmitInfo submitInfo;
                submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;

                VkSemaphore[] waitSemaphores = [cast(VkSemaphore) readySemaphores[currentImage]];
                VkPipelineStageFlags[] waitStages = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT];
                submitInfo.waitSemaphoreCount = 1;
                submitInfo.pWaitSemaphores = waitSemaphores.ptr;
                submitInfo.pWaitDstStageMask = waitStages.ptr;
                submitInfo.commandBufferCount = 1;
                submitInfo.pCommandBuffers = cast(VkCommandBuffer*) &commandBuffers[imageIndex];

                VkSemaphore[] signalSemaphores = [cast(VkSemaphore) doneSemaphores[currentImage]];
                submitInfo.signalSemaphoreCount = 1;
                submitInfo.pSignalSemaphores = signalSemaphores.ptr;

                VkQueue graphicsQueue;
                vkGetDeviceQueue(
                    Application.instance.backendContext.device,
                    Application.instance.backendContext.graphicsQueueIndex,
                    0,
                    &graphicsQueue
                );

                Application.instance.backendContext.device.vkResetFences(1, cast(VkFence*) &fences[currentImage]);
                vkSuccessOrDie!vkQueueSubmit(graphicsQueue, 1, &submitInfo, cast(VkFence) fences[currentImage]);

                VkPresentInfoKHR presentInfo = {
                    sType: VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
                    waitSemaphoreCount: 1,
                    pWaitSemaphores: signalSemaphores.ptr,
                    swapchainCount: 1,
                    pSwapchains: [cast(VkSwapchainKHR) swapchain].ptr,
                    pImageIndices: &imageIndex,
                    pResults: null,
                };

                result = vkQueuePresentKHR(cast(VkQueue) presentQueue, &presentInfo);
                if(result == VK_ERROR_OUT_OF_DATE_KHR || result == VK_SUBOPTIMAL_KHR) {
                    createSwapchain();
                } else if (result != VK_SUCCESS) {
                    throw new VulkanException!vkQueuePresentKHR();
                }

                currentImage = (currentImage + 1) % imageCount;
            }
        });
    }

    private void createSwapchain() @trusted {
        Application.instance.backendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
        cast(VkSurfaceKHR) vkSurface,
        cast(VkSurfaceCapabilitiesKHR*) &drawPayload.capabilities
        );

        uint sfBufCount;
        Application.instance.backendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceFormatsKHR(
        cast(VkSurfaceKHR_handle*) vkSurface,
        &sfBufCount,
        null
        );

        if (sfBufCount == 0) {
            throw new VulkanException!vkGetPhysicalDeviceSurfaceFormatsKHR();
        }

        VkSurfaceFormatKHR[] surfaceFormats = new VkSurfaceFormatKHR[](sfBufCount);
        Application.instance.backendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceFormatsKHR(
        cast(VkSurfaceKHR_handle*) vkSurface,
        &sfBufCount,
        surfaceFormats.ptr
        );

        if (!surfaceFormats.canFind!((o) => o.format == VK_FORMAT_B8G8R8A8_SRGB &&
        o.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)) {
            throw new VulkanException!vkGetPhysicalDeviceSurfaceFormatsKHR();
        }

        VkSwapchainCreateInfoKHR vkSwapchainCreateInfo = {
            pNext                   : null,
            flags                   : 0,
            surface                 : cast(VkSurfaceKHR_handle*) vkSurface,
            minImageCount           : drawPayload.capabilities.minImageCount,
            imageFormat             : VK_FORMAT_B8G8R8A8_SRGB,
            imageColorSpace         : VK_COLOR_SPACE_SRGB_NONLINEAR_KHR,
            imageExtent             : drawPayload.capabilities.currentExtent,
            imageArrayLayers        : 1,
            imageUsage              : VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT |
            VK_IMAGE_USAGE_TRANSFER_SRC_BIT |
            VK_IMAGE_USAGE_TRANSFER_DST_BIT,
            imageSharingMode        : VK_SHARING_MODE_EXCLUSIVE,
            queueFamilyIndexCount   : 0,  // Because of the exclusive sharing mode.
            pQueueFamilyIndices     : null,
            preTransform            : VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR,
            compositeAlpha          : VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR,
            presentMode             : VK_PRESENT_MODE_FIFO_KHR,
            clipped                 : VK_FALSE,
            oldSwapchain            : cast(VkSwapchainKHR) drawPayload.swapchain
        };

        uint[] queueFamilies = [Application.instance.backendContext.graphicsQueueIndex, drawPayload.presentQueueIndex];
        if (Application.instance.backendContext.graphicsQueueIndex != drawPayload.presentQueueIndex) {
            vkSwapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT;
            vkSwapchainCreateInfo.queueFamilyIndexCount = cast(uint) queueFamilies.length;
            vkSwapchainCreateInfo.pQueueFamilyIndices = queueFamilies.ptr;
        } else {
            vkSwapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
            vkSwapchainCreateInfo.queueFamilyIndexCount = 0;
            vkSwapchainCreateInfo.pQueueFamilyIndices = null;
        }

        Application.instance.backendContext.device.vkSuccessOrDie!vkCreateSwapchainKHR(
            &vkSwapchainCreateInfo,
            null,
            cast(VkSwapchainKHR*) &drawPayload.swapchain
        );

        vkGetSwapchainImagesKHR(
            Application.instance.backendContext.device,
            cast(VkSwapchainKHR) drawPayload.swapchain,
            cast(uint*) &drawPayload.imageCount,
            null
        );

        drawPayload.images = new VkImage[](drawPayload.imageCount);
        vkGetSwapchainImagesKHR(
            Application.instance.backendContext.device,
            cast(VkSwapchainKHR) drawPayload.swapchain,
            cast(uint*) &drawPayload.imageCount,
            cast(VkImage*) drawPayload.images.ptr
        );

        VkCommandPoolCreateInfo commandPoolCreateInfo = {
            queueFamilyIndex: Application.instance.backendContext.graphicsQueueIndex
        };

        Application.instance.backendContext.device.vkSuccessOrDie!vkCreateCommandPool(&commandPoolCreateInfo, null, cast(VkCommandPool*) &drawPayload.commandPool);

        VkCommandBufferAllocateInfo allocateInfo = {
            commandPool: cast(VkCommandPool) drawPayload.commandPool,
            commandBufferCount: drawPayload.imageCount
        };

        drawPayload.commandBuffers = new VkCommandBuffer[](drawPayload.imageCount);
        Application.instance.backendContext.device.vkSuccessOrDie!vkAllocateCommandBuffers(&allocateInfo, cast(VkCommandBuffer*) drawPayload.commandBuffers.ptr);
        Application.instance.backendContext.device.vkSuccessOrDie!vkResetCommandPool(cast(VkCommandPool) drawPayload.commandPool, 0);


        uint width = min(
        max(drawPayload.capabilities.currentExtent.width, drawPayload.capabilities.minImageExtent.width),
        drawPayload.capabilities.maxImageExtent.width
        );

        uint height = min(
        max(drawPayload.capabilities.currentExtent.height, drawPayload.capabilities.minImageExtent.height),
        drawPayload.capabilities.maxImageExtent.height
        );

        destroy(drawPayload.readySemaphores);
        destroy(drawPayload.doneSemaphores);
        destroy(drawPayload.fences);
        drawPayload.readySemaphores = new VkSemaphore[](drawPayload.imageCount);
        drawPayload.doneSemaphores = new VkSemaphore[](drawPayload.imageCount);
        drawPayload.fences = new VkFence[](drawPayload.imageCount);

        VkSemaphoreCreateInfo semaphoreInfo = {
            sType: VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
        };

        VkFenceCreateInfo fenceInfo = {
            sType: VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
            flags: VK_FENCE_CREATE_SIGNALED_BIT
        };

        if (vkvgSurface)
            destroy(vkvgSurface);

        vkvgSurface = new super_.forms.drawing.Surface(
        Application.instance.backendContext.vkvgDevice,
        width,
        height
        );
        vkvgSurface.clear();

        for (int imageIndex = 0; imageIndex < drawPayload.imageCount; imageIndex++) {
            Application.instance.backendContext.device.vkSuccessOrDie!vkCreateSemaphore(&semaphoreInfo, null, cast(VkSemaphore*) &drawPayload.readySemaphores[imageIndex]);
            Application.instance.backendContext.device.vkSuccessOrDie!vkCreateSemaphore(&semaphoreInfo, null, cast(VkSemaphore*) &drawPayload.doneSemaphores[imageIndex]);
            Application.instance.backendContext.device.vkSuccessOrDie!vkCreateFence(&fenceInfo, null, cast(VkFence*) &drawPayload.fences[imageIndex]);

            VkImage image = cast(VkImage) drawPayload.images[imageIndex];
            VkCommandBuffer commandBuffer = cast(VkCommandBuffer) drawPayload.commandBuffers[imageIndex];

            VkCommandBufferBeginInfo beginInfo = {};
            commandBuffer.vkSuccessOrDie!vkBeginCommandBuffer(&beginInfo);

            set_image_layout(commandBuffer, image, VK_IMAGE_ASPECT_COLOR_BIT,
            VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);

            set_image_layout(commandBuffer, vkvgSurface.vkImage, VK_IMAGE_ASPECT_COLOR_BIT,
            VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);

            VkImageBlit imageBlit = {
                srcSubresource: VkImageSubresourceLayers (VK_IMAGE_ASPECT_COLOR_BIT, 1, 0),
                srcOffsets: VkOffset3D (width, height, 1),
                dstSubresource: VkImageSubresourceLayers (VK_IMAGE_ASPECT_COLOR_BIT, 1, 0),
                dstOffsets: VkOffset3D (width, height, 1)
            };

            commandBuffer.vkCmdBlitImage(
            image,
            VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
            vkvgSurface.vkImage,
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
            1,
            &imageBlit,
            VK_FILTER_NEAREST
            );

            set_image_layout(commandBuffer, image, VK_IMAGE_ASPECT_COLOR_BIT,
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
            VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
            set_image_layout(commandBuffer, vkvgSurface.vkImage, VK_IMAGE_ASPECT_COLOR_BIT,
            VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
            VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

            commandBuffer.vkSuccessOrDie!vkEndCommandBuffer();
        }

        vkDeviceWaitIdle(Application.instance.backendContext.device);
    }

    /++
     + Hide window.
     +/
    void hide() {
        nativeWindow.hide();
    }

    /++
     + Show window.
     +/
    void show() {
        nativeWindow.show();
    }

    /++
     + Get VkSurfaceKHR for the window.
     +/
    private shared(VkSurfaceKHR) vkSurface() {
        return nativeWindow.vkSurface;
    }
}

extern(C) void set_image_layout(VkCommandBuffer cmdBuff, VkImage image, VkImageAspectFlags aspectMask, VkImageLayout old_image_layout,
VkImageLayout new_image_layout, VkPipelineStageFlags src_stages, VkPipelineStageFlags dest_stages);
