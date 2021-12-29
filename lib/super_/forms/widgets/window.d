module super_.forms.widgets.window;

import erupted;
import skia;
import std.algorithm;
import std.typecons;
import super_.forms;
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

    private SkSurface[] surfaces;
    private VkSwapchainKHR swapchain;
    private VkSurfaceCapabilitiesKHR capabilities;
    private VkSemaphore[] semaphores;
    private uint imageCount;
    private uint currentImage = 0;

    this() @trusted {
        nativeWindow = Application.instance.backend.createWindow(this);
        this.size(800, 600);

        Application.instance.skiaBackendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
            cast(VkSurfaceKHR_handle*) vkSurface,
            &capabilities
        );

        uint sfBufCount;
        Application.instance.skiaBackendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceFormatsKHR(
            cast(VkSurfaceKHR_handle*) vkSurface,
            &sfBufCount,
            null
        );

        if (sfBufCount == 0) {
            throw new VulkanException!vkGetPhysicalDeviceSurfaceFormatsKHR();
        }

        VkSurfaceFormatKHR[] surfaceFormats = new VkSurfaceFormatKHR[](sfBufCount);
        Application.instance.skiaBackendContext.physicalDevice.vkSuccessOrDie!vkGetPhysicalDeviceSurfaceFormatsKHR(
            cast(VkSurfaceKHR_handle*) vkSurface,
            &sfBufCount,
            surfaceFormats.ptr
        );

        if (!surfaceFormats.canFind!((o) => o.format == VK_FORMAT_B8G8R8A8_SRGB &&
            o.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)) {
            throw new VulkanException!vkGetPhysicalDeviceSurfaceFormatsKHR();
        }

        VkSurfaceFormatKHR format = {
            format: VK_FORMAT_B8G8R8A8_SRGB,
            colorSpace: VK_COLOR_SPACE_SRGB_NONLINEAR_KHR
        };

        uint queueCount;
        vkGetPhysicalDeviceQueueFamilyProperties(Application.instance.skiaBackendContext.physicalDevice, &queueCount, null);

        VkQueueFamilyProperties[] props = new VkQueueFamilyProperties[](queueCount);
        vkGetPhysicalDeviceQueueFamilyProperties(Application.instance.skiaBackendContext.physicalDevice, &queueCount, props.ptr);

        uint graphicsQueueIndex = queueCount;
        for (uint i = 0; i < queueCount; i++) {
            if (props[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) {
                graphicsQueueIndex = i;
                break;
            }
        }
        if (graphicsQueueIndex == queueCount) {
            throw new VulkanException!vkGetPhysicalDeviceQueueFamilyProperties();
        }

        uint queueIndex = queueCount;
        for (uint i = 0; i < queueCount; i++) {
            if (nativeWindow.canPresent(
                Application.instance.skiaBackendContext.physicalDevice,
                i
            )) {
                queueIndex = i;
                break;
            }
        }
        if (queueIndex == queueCount) {
            throw new VulkanException!vkGetPhysicalDeviceQueueFamilyProperties();
        }

        // from flutter code
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
            oldSwapchain            : VK_NULL_HANDLE
        };

        uint[] queueFamilies = [graphicsQueueIndex, queueIndex];
        if (graphicsQueueIndex != queueIndex) {
            vkSwapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT;
            vkSwapchainCreateInfo.queueFamilyIndexCount = cast(uint) queueFamilies.length;
            vkSwapchainCreateInfo.pQueueFamilyIndices = queueFamilies.ptr;
        } else {
            vkSwapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
            vkSwapchainCreateInfo.queueFamilyIndexCount = 0;
            vkSwapchainCreateInfo.pQueueFamilyIndices = null;
        }

        swapchain = VK_NULL_HANDLE;

        Application.instance.skiaBackendContext.device.vkSuccessOrDie!vkCreateSwapchainKHR(
            &vkSwapchainCreateInfo,
            null,
            &swapchain
        );

        VkQueue presentQueue;
        vkGetDeviceQueue(
            Application.instance.skiaBackendContext.device,
            queueIndex,
            0,
            &presentQueue,
        );

        vkGetSwapchainImagesKHR(
            Application.instance.skiaBackendContext.device,
            swapchain,
            &imageCount,
            null
        );

        VkImage[] images = new VkImage[](imageCount);
        vkGetSwapchainImagesKHR(
            Application.instance.skiaBackendContext.device,
            swapchain,
            &imageCount,
            images.ptr
        );

        semaphores = new VkSemaphore[](imageCount);

        VkImageLayout[] imageLayouts = new VkImageLayout[](imageCount);
        surfaces = new SkSurface[](imageCount);

        uint width = min(
            max(capabilities.currentExtent.width, capabilities.minImageExtent.width),
            capabilities.maxImageExtent.width
        );

        uint height = min(
            max(capabilities.currentExtent.height, capabilities.minImageExtent.height),
            capabilities.maxImageExtent.height
        );

        SkColorSpace colorspace = SkColorSpace.newSRGB();

        for (uint i = 0; i < imageCount; ++i) {
            imageLayouts[i] = VK_IMAGE_LAYOUT_UNDEFINED;

            GrVkImageInfo info = {
                image: images[i],
                alloc: GrVkAlloc(),
                imageLayout: VK_IMAGE_LAYOUT_UNDEFINED,
                imageTiling: VK_IMAGE_TILING_OPTIMAL,
                format: VK_FORMAT_B8G8R8A8_SRGB,
                imageUsageFlags: VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT |
                    VK_IMAGE_USAGE_TRANSFER_SRC_BIT |
                    VK_IMAGE_USAGE_TRANSFER_DST_BIT,
                levelCount: 1,
                currentQueueFamily: queueIndex,
                sharingMode: vkSwapchainCreateInfo.imageSharingMode,
            };

            GrBackendRenderTarget backendRT = new GrBackendRenderTarget(
                width,
                height,
                1,
                info
            );

            surfaces[i] = new SkSurface(
                Application.instance.grContext,
                backendRT,
                GrSurfaceOrigin.topLeft,
                SkColorType.rgba8888,
                colorspace,
                new SkSurfaceProps(0, SkPixelGeometry.unknown)
            );

            //const(VkSemaphoreCreateInfo) semaphoreInfo = {
            //    sType: VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
            //    pNext: null,
            //    flags: 0,
            //};
            //
            //vkSuccessOrDie!vkCreateSemaphore(
            //    Application.instance.skiaBackendContext.device,
            //    &semaphoreInfo,
            //    null,
            //    &semaphores[i]
            //);
        }
    }

    /++
     + Render the window content
     +/
    void render() @trusted {
        currentImage = ++currentImage % imageCount;

        uint imageIndex;
        vkSuccessOrDie!vkAcquireNextImageKHR(
            Application.instance.skiaBackendContext.device,
            swapchain,
            ulong.max,
            semaphores[currentImage],
            VK_NULL_HANDLE,
            &imageIndex
        );

        SkSurface surface = surfaces[imageIndex];
        GrBackendSemaphore semaphore = GrBackendSemaphore();
        semaphore.initVulkan(semaphores[currentImage]);
        (cast(SkSurface_handle*) surface.handle).wait(1, &semaphore);
        
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
