# Inherit common mobile infinity stuff
$(call inherit-product, vendor/infinity/config/common.mk)

# Themes
PRODUCT_PACKAGES += \
    ThemePicker \
    ThemesStub
