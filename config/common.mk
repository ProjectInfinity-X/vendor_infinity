# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= Project Infinity X

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

# Protobuf - Workaround for prebuilt Qualcomm HAL
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-3.9.1-vendorcompat \
    libprotobuf-cpp-lite-3.9.1-vendorcompat

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.usb.config=adb
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.usb.config=none

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Audio
$(call inherit-product, vendor/infinity/audio/audio.mk)

# Additional Packages
include vendor/extras/prebuilts.mk

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/infinity/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/infinity/prebuilt/common/bin/50-infinity.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-infinity.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/addon.d/50-infinity.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/infinity/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/infinity/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# Blurs
ifeq ($(TARGET_SUPPORTS_BLUR),true)
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.supports_background_blur=1 \
    ro.launcher.blur.appLaunch=0 \
    persist.sys.sf.disable_blurs=1
endif

# BootAnimation
PRODUCT_COPY_FILES += \
	vendor/infinity/prebuilt/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip

# Some permissions
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/privapp-permissions-lineagehw.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-lineagehw.xml

# infinity-specific init rc file
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.infinity-system_ext.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.infinity-system_ext.rc

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.nfc.beam.xml

# Display
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    debug.sf.frame_rate_multiple_threshold=60 \
    ro.surface_flinger.enable_frame_rate_override=false

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable SystemUIDialog volume panel
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    sys.fflag.override.settings_volume_panel_in_systemui=true

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=log

# Gapps
ifeq ($(WITH_GAPPS),true)
$(call inherit-product, vendor/gms/common/common-vendor.mk)

ifeq ($(INFINITY_BUILD_TYPE),OFFICIAL)
# UpdaterGMSOverlay
PRODUCT_PACKAGES += \
    UpdaterGMSOverlay
endif
endif

# Gboard side padding
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.ime.kb_pad_port_l=4 \
    ro.com.google.ime.kb_pad_port_r=4 \
    ro.com.google.ime.kb_pad_land_l=64 \
    ro.com.google.ime.kb_pad_land_r=64

# Google Photos Pixel Exclusive XML
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/sysconfig/pixel_2016_exclusive.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/pixel_2016_exclusive.xml

# Overlay
PRODUCT_PRODUCT_PROPERTIES += \
    ro.boot.vendor.overlay.theme=com.android.internal.systemui.navbar.gestural;com.google.android.systemui.gxoverlay

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
WITH_DEXPREOPT_DEBUG_INFO := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# Partition overlay
PRODUCT_COPY_FILES += \
    vendor/infinity/overlay/partition_order.xml:$(TARGET_COPY_OUT_PRODUCT)/overlay/partition_order.xml

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

TARGET_DISABLE_EPPE ?= true
ifneq ($(TARGET_DISABLE_EPPE),true)
# Require all requested packages to exist
$(call enforce-product-packages-exist-internal,$(wildcard device/*/$(INFINITY_BUILD)/$(TARGET_PRODUCT).mk),product_manifest.xml rild Calendar Launcher3 Launcher3Go Launcher3QuickStep Launcher3QuickStepGo android.hidl.memory@1.0-impl.vendor vndk_apex_snapshot_package)
endif

# Relax Broken Library Check
PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

# BtHelper
PRODUCT_PACKAGES += \
    BtHelper

# Charger
PRODUCT_PACKAGES += \
    charger_res_images

ifneq ($(WITH_INFINITY_CHARGER),false)
PRODUCT_PACKAGES += \
    infinity_charger_animation \
    infinity_charger_animation_vendor
endif

# Call Recording
TARGET_CALL_RECORDING_SUPPORTED ?= true
ifneq ($(TARGET_CALL_RECORDING_SUPPORTED),false)
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/com.google.android.apps.dialer.call_recording_audio.features.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.google.android.apps.dialer.call_recording_audio.features.xml
endif

# Extra tools in infinity
PRODUCT_PACKAGES += \
    bash \
    curl \
    getcap \
    htop \
    nano \
    setcap \
    vim

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mke2fs \
    mkfs.ntfs \
    mount.ntfs

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/fsck.ntfs \
    system/bin/mkfs.ntfs \
    system/bin/mount.ntfs \
    system/%/libfuse-lite.so \
    system/%/libntfs-3g.so

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.openssh.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.openssh.rc

# ThemeOverlays
include packages/overlays/Themes/themes.mk

# rsync
PRODUCT_PACKAGES += \
    rsync

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# One Handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Disable remote keyguard animation
PRODUCT_SYSTEM_PROPERTIES += \
    persist.wm.enable_remote_keyguard_animation=0

# Clean up packages cache to avoid wrong strings and resources
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/clean_cache.sh:system/bin/clean_cache.sh

# Pixel customization
TARGET_SUPPORTS_GOOGLE_BATTERY ?= false

# Protobuf - Workaround for prebuilt Qualcomm HAL
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-3.9.1-vendorcompat \
    libprotobuf-cpp-lite-3.9.1-vendorcompat

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \
    Launcher3QuickStep

# Speed profile services and wifi-service to reduce RAM and storage
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := frameworks/base/config/boot-image-profile.txt

PRODUCT_PACKAGE_OVERLAYS += \
    vendor/infinity/overlay/common \

PRODUCT_PACKAGES += \
    CustomFontPixelLauncherOverlay \
    DocumentsUIOverlay \
    NavigationBarNoHintOverlay \
    NetworkStackOverlay

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/infinity/build/target/product/security/infinity

include vendor/infinity/config/version.mk
include vendor/infinity/config/packages.mk
$(call inherit-product, vendor/infinity/config/clocks.mk)

# Sounds (default)
PRODUCT_PROPERTY_OVERRIDES := \
    ro.config.ringtone=vibe.ogg \
    ro.config.notification_sound=Titan.ogg \
    ro.config.alarm_alert=Oxygen.ogg

include vendor/infinity/config/pixel_props.mk

ifeq ($(INFINITY_BUILD_TYPE),OFFICIAL)
# Updater
PRODUCT_PACKAGES += \
    Updater

PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.infinity-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.infinity-updater.rc
endif

# Signing Keys
include vendor/infinity-priv/keys/keys.mk
