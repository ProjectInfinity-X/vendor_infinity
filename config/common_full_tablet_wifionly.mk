# Inherit common Infinity stuff
$(call inherit-product, vendor/infinity/config/common.mk)

# Required packages
PRODUCT_PACKAGES += \
    androidx.window.extensions

# Settings
PRODUCT_PRODUCT_PROPERTIES += \
    persist.settings.large_screen_opt.enabled=true

$(call inherit-product, vendor/infinity/config/wifionly.mk)
