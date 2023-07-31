# Inherit full common infinity stuff
$(call inherit-product, vendor/infinity/config/common_full.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

# Include infinity LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/infinity/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/infinity/overlay/dictionaries

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode?=true

$(call inherit-product, vendor/infinity/config/telephony.mk)
