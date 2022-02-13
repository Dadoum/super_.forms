module super_.forms.widgets.window;

import erupted;
import std.algorithm;
import std.typecons;
import super_.forms;
import super_.forms.drawing;
import tinyevent;

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

    private VkSwapchainKHR swapchain = VK_NULL_HANDLE;
    private VkSurfaceCapabilitiesKHR capabilities;
    private VkCommandPool commandPool;
    private VkCommandBuffer[] commandBuffers;
    private VkFence drawFence;
    private VkImage[] images;
    private VkQueue presentQueue;
    private uint presentQueueIndex;
    private VkSemaphore[] drawSemaphores;
    private uint imageCount;
    private uint currentImage = 0;

    private super_.forms.drawing.Surface vkvgSurface;

    ~this() @trusted {
        if (vkvgSurface)
            destroy(vkvgSurface);
        nativeWindow.hide();
        Application.instance.backendContext.device.vkDestroySwapchainKHR(swapchain, null);
        Application.instance.backendContext.device.vkDestroyCommandPool(commandPool, null);
        destroy(nativeWindow);
    }

    this() @trusted {
        nativeWindow = Application.instance.backend.createWindow(this);
        this.size(800, 600);

        uint queueCount;
        vkGetPhysicalDeviceQueueFamilyProperties(Application.instance.backendContext.physicalDevice, &queueCount, null);

        VkQueueFamilyProperties[] props = new VkQueueFamilyProperties[](queueCount);
        vkGetPhysicalDeviceQueueFamilyProperties(Application.instance.backendContext.physicalDevice, &queueCount, props.ptr);

        presentQueueIndex = queueCount;
        for (uint i = 0; i < queueCount; i++) {
            if (nativeWindow.canPresent(
                Application.instance.backendContext.physicalDevice,
                i
            )) {
                presentQueueIndex = i;
                break;
            }
        }
        if (presentQueueIndex == queueCount) {
            throw new VulkanException!vkGetPhysicalDeviceQueueFamilyProperties();
        }

        vkGetDeviceQueue(
            Application.instance.backendContext.device,
            presentQueueIndex,
            0,
            &presentQueue,
        );

        VkImageLayout[] imageLayouts = new VkImageLayout[](imageCount);

        createSwapchain();

        this.render();
    }

    private void createSwapchain() @trusted {
        Application.instance.backendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
        cast(VkSurfaceKHR_handle*) vkSurface,
        &capabilities
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
            minImageCount           : capabilities.minImageCount,
            imageFormat             : VK_FORMAT_B8G8R8A8_SRGB,
            imageColorSpace         : VK_COLOR_SPACE_SRGB_NONLINEAR_KHR,
            imageExtent             : capabilities.currentExtent,
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
            oldSwapchain            : swapchain
        };

        uint[] queueFamilies = [Application.instance.backendContext.graphicsQueueIndex, presentQueueIndex];
        if (Application.instance.backendContext.graphicsQueueIndex != presentQueueIndex) {
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
            &swapchain
        );

        vkGetSwapchainImagesKHR(
            Application.instance.backendContext.device,
            swapchain,
            &imageCount,
            null
        );

        images = new VkImage[](imageCount);
        vkGetSwapchainImagesKHR(
            Application.instance.backendContext.device,
            swapchain,
            &imageCount,
            images.ptr
        );

        VkCommandPoolCreateInfo commandPoolCreateInfo = {
            queueFamilyIndex: Application.instance.backendContext.graphicsQueueIndex
        };

        Application.instance.backendContext.device.vkSuccessOrDie!vkCreateCommandPool(&commandPoolCreateInfo, null, &commandPool);

        VkCommandBufferAllocateInfo allocateInfo = {
            commandPool: commandPool,
            commandBufferCount: imageCount
        };

        commandBuffers = new VkCommandBuffer[](imageCount);
        Application.instance.backendContext.device.vkSuccessOrDie!vkAllocateCommandBuffers(&allocateInfo, commandBuffers.ptr);
        Application.instance.backendContext.device.vkSuccessOrDie!vkResetCommandPool(commandPool, 0);

        destroy(drawSemaphores);
        drawSemaphores = new VkSemaphore[](imageCount);

        foreach (ref semaphore; drawSemaphores) {
            const(VkSemaphoreCreateInfo) info = const VkSemaphoreCreateInfo();
            Application.instance.backendContext.device.vkSuccessOrDie!vkCreateSemaphore(&info, null, &semaphore);
        }

        uint width = min(
        max(capabilities.currentExtent.width, capabilities.minImageExtent.width),
        capabilities.maxImageExtent.width
        );

        uint height = min(
        max(capabilities.currentExtent.height, capabilities.minImageExtent.height),
        capabilities.maxImageExtent.height
        );

        if (vkvgSurface)
            destroy(vkvgSurface);

        vkvgSurface = new super_.forms.drawing.Surface(
            Application.instance.backendContext.vkvgDevice,
            width,
            height
        );
        vkvgSurface.clear();

        VkFenceCreateInfo fenceInfo = {

        };
        Application.instance.backendContext.device.vkSuccessOrDie!vkCreateFence(&fenceInfo, null, &drawFence);

        for (int imageIndex = 0; imageIndex < imageCount; imageIndex++) {
            VkImage image = images[imageIndex];
            VkCommandBuffer commandBuffer = commandBuffers[imageIndex];

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
     + Render the window content
     +/
    package(super_.forms) final void render() @trusted {
        uint imageIndex;
        if (!vkAcquireNextImageKHR(
            Application.instance.backendContext.device,
            swapchain,
            ulong.max,
            drawSemaphores[currentImage],
            VK_NULL_HANDLE,
            &imageIndex
        )) {
            import std.stdio;
            createSwapchain();
            return;
        }

        VkPipelineStageFlags dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        VkSubmitInfo submit_info = {
            sType: VK_STRUCTURE_TYPE_SUBMIT_INFO,
            commandBufferCount: 1,
            signalSemaphoreCount: 1,
            pSignalSemaphores: &drawSemaphores[imageIndex],
            waitSemaphoreCount: 0,
            pWaitSemaphores: null,
            pWaitDstStageMask: &dstStageMask,
            pCommandBuffers: &commandBuffers[currentImage]
        };

        vkQueueSubmit(presentQueue, 1, &submit_info, drawFence);

        VkPresentInfoKHR presentInfo = {
            swapchainCount: 1,
            pSwapchains: &swapchain,
            waitSemaphoreCount: 1,
            pWaitSemaphores: &drawSemaphores[imageIndex]
        };

        vkQueuePresentKHR(presentQueue, &presentInfo);

        import std.stdio;
        writeln("zzzzz");
        super_.forms.drawing.Context ctx = new super_.forms.drawing.Context(vkvgSurface);
        ctx.setSourceRgb(.1, .1, .1);
        ctx.paint();
        destroy(ctx);
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
