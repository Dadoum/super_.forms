module super_.forms.renderer.vulkan.vulkanrendercompatiblebackend;

import super_.forms.renderer.renderer;
import super_.forms.renderer.vulkan;
import super_.forms.windowing.defs;

shared synchronized interface VulkanRenderCompatibleBackend: Backend, BackendCompatibleWith!VulkanRenderer {
    version (VulkanRender) {
        public import erupted;

        /++
         + VkExtensions required for backend.
         +/
        string[] requiredExtensions() @safe;
    }
}
