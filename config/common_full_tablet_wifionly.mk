# Inherit common Infinity stuff
$(call inherit-product, vendor/infinity/config/common.mk)

# Required packages
PRODUCT_PACKAGES += \
    androidx.window.extensions

$(call inherit-product, vendor/infinity/config/wifionly.mk)
