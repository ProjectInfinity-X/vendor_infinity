# Inherit common mobile infinity stuff
$(call inherit-product, vendor/infinity/config/common.mk)

# Include AOSP audio files
include vendor/infinity/config/aosp_audio.mk

# Themes
PRODUCT_PACKAGES += \
    ThemePicker \
    ThemesStub
