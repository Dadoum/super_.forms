module skia.gpu.vk.grvktypes;

import erupted;
import skia;

struct GrVkYcbcrConversionInfo {
    bool opEquals(ref const(GrVkYcbcrConversionInfo) that) const {
        // Invalid objects are not required to have all other fields initialized or matching.
        if (!this.isValid() && !that.isValid()) {
            return true;
        }
        return this.fFormat == that.fFormat &&
        this.fExternalFormat == that.fExternalFormat &&
        this.fYcbcrModel == that.fYcbcrModel &&
        this.fYcbcrRange == that.fYcbcrRange &&
        this.fXChromaOffset == that.fXChromaOffset &&
        this.fYChromaOffset == that.fYChromaOffset &&
        this.fChromaFilter == that.fChromaFilter &&
        this.fForceExplicitReconstruction == that.fForceExplicitReconstruction;
    }

    bool isValid() const { return fYcbcrModel != VK_SAMPLER_YCBCR_MODEL_CONVERSION_RGB_IDENTITY; }

    VkFormat fFormat = VK_FORMAT_UNDEFINED;
    uint64_t fExternalFormat = 0;
    VkSamplerYcbcrModelConversion fYcbcrModel = VK_SAMPLER_YCBCR_MODEL_CONVERSION_RGB_IDENTITY;
    VkSamplerYcbcrRange fYcbcrRange = VK_SAMPLER_YCBCR_RANGE_ITU_FULL;
    VkChromaLocation fXChromaOffset = VK_CHROMA_LOCATION_COSITED_EVEN;
    VkChromaLocation fYChromaOffset = VK_CHROMA_LOCATION_COSITED_EVEN;
    VkFilter fChromaFilter = VK_FILTER_NEAREST;
    VkBool32 fForceExplicitReconstruction = false;
    VkFormatFeatureFlags fFormatFeatures = 0;
}

struct GrVkAlloc {
    // can be VK_NULL_HANDLE iff is an RT and is borrowed
    VkDeviceMemory    fMemory = VK_NULL_HANDLE;
    VkDeviceSize      fOffset = 0;
    VkDeviceSize      fSize = 0;  // this can be indeterminate iff Tex uses borrow semantics
    uint32_t          fFlags = 0;
    long              fBackendMemory = 0; // handle to memory allocated via GrVkMemoryAllocator.

    enum Flag {
        kNoncoherent_Flag = 0x1,   // memory must be flushed to device after mapping
        kMappable_Flag    = 0x2,   // memory is able to be mapped.
    };

    bool opEquals(ref const(GrVkAlloc) that) const {
        return fMemory == that.fMemory && fOffset == that.fOffset && fSize == that.fSize &&
        fFlags == that.fFlags && fUsesSystemHeap == that.fUsesSystemHeap;
    }

  package(skia):
    bool fUsesSystemHeap = false;
};

struct GrVkImageInfo {
    VkImage                  image = VK_NULL_HANDLE;
    GrVkAlloc                alloc;
    VkImageTiling            imageTiling = VK_IMAGE_TILING_OPTIMAL;
    VkImageLayout            imageLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    VkFormat                 format = VK_FORMAT_UNDEFINED;
    VkImageUsageFlags        imageUsageFlags = 0;
    uint32_t                 sampleCount = 1;
    uint32_t                 levelCount = 0;
    uint32_t                 currentQueueFamily = VK_QUEUE_FAMILY_IGNORED;
    bool                     protected_ = false;
    GrVkYcbcrConversionInfo  ycbcrConversionInfo;
    VkSharingMode            sharingMode = VK_SHARING_MODE_EXCLUSIVE;
}
