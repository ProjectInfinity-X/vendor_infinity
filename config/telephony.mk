# GMS
ifeq ($(WITH_GMS),true)
WITH_GMS_COMMS_SUITE := true

ifeq ($(TARGET_BUILD_GOOGLE_TELEPHONY),true)
$(call inherit-product, vendor/bcr/bcr.mk)
endif
endif

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/sensitive_pn.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sensitive_pn.xml
	
# World APN list
PRODUCT_PACKAGES += \
    apns-conf.xml

# Telephony packages
PRODUCT_PACKAGES += \
    messaging \
    Stk

# Tethering - allow without requiring a provisioning app
# (for devices that check this)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    net.tethering.noprovisioning=true

# Disable mobile data by default
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.android.mobiledata=false
