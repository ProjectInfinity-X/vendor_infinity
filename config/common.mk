# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)
$(call inherit-product-if-exists, vendor/extras/prebuilts.mk)
$(call inherit-product, vendor/pixel-style/config/common.mk)

PRODUCT_BRAND ?= Project Infinity X
WITH_GAPPS ?= true

# Allow vendor prebuilt repos to exclude themselves from bp scanning
-include $(sort $(wildcard vendor/*/*/exclude-bp.mk))

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(PRODUCT_IS_ATV),true)
ifeq ($(PRODUCT_ATV_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.oem.key1=ATV00100020
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.oem.key1=$(PRODUCT_ATV_CLIENTID_BASE)
endif
endif

DONT_DEXPREOPT_PREBUILTS := true

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
ifdef WITH_ADB_INSECURE
# Forcebly disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# AvatarPicker
PRODUCT_PACKAGES += \
    AvatarPicker

# Enable Material Design 3 Expressive
PRODUCT_PRODUCT_PROPERTIES += \
    is_expressive_design_enabled=true

# Cloned app exemption
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/sysconfig/preinstalled-packages-platform-infinity-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/preinstalled-packages-platform-infinity-product.xml

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/infinity/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/infinity/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/infinity/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif

# Lineage-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/lineage-sysconfig.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/lineage-sysconfig.xml

# Lineage-specific init rc file
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.lineage-system_ext.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.lineage-system_ext.rc

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Credential storage
PRODUCT_PACKAGES += \
    android.software.credentials.prebuilt.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Columbus
PRODUCT_PACKAGES += \
    ColumbusService

# Component overrides
PRODUCT_PACKAGES += \
    lineage-component-overrides.xml

# This is Lineage!
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/org.lineageos.android.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.android.xml

# Enable transitional log for Privileged permissions
PRODUCT_PRODUCT_PROPERTIES += \
    ro.control_privapp_permissions=log

ifneq ($(TARGET_DISABLE_LINEAGE_SDK), true)
# Lineage SDK
include vendor/infinity/config/lineage_sdk_common.mk
endif

ART_BUILD_HOST_DEBUG := false
ART_BUILD_TARGET_DEBUG := false
PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
WITH_DEXPREOPT_DEBUG_INFO := false

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# Disable dex2oat debug
USE_DEX2OAT_DEBUG := false

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Bootanimation
 include vendor/infinity/config/bootanimation.mk

# Build Manifest
PRODUCT_PACKAGES += \
    build-manifest

# Blurs
 PRODUCT_SYSTEM_EXT_PROPERTIES += \
     ro.sf.blurs_are_expensive=1 \
     ro.surface_flinger.supports_background_blur=1 \
     ro.launcher.blur.appLaunch=0 \
     persist.sys.sf.disable_blurs=1

# Lineage packages
ifeq ($(PRODUCT_IS_ATV),)
PRODUCT_PACKAGES += \
    ExactCalculator
endif

ifeq ($(PRODUCT_IS_AUTOMOTIVE),)
PRODUCT_PACKAGES += \
    LineageParts
endif

PRODUCT_PACKAGES += \
    LineageSettingsProvider \
    Updater

PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.lineage-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.lineage-updater.rc

# DeviceAsWebcam
ifeq ($(TARGET_BUILD_DEVICE_AS_WEBCAM), true)
    PRODUCT_PACKAGES += \
        DeviceAsWebcam

    PRODUCT_VENDOR_PROPERTIES += \
        ro.usb.uvc.enabled=true
endif

# Broken config
PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

# Config
PRODUCT_PACKAGES += \
    SimpleSettingsConfig

# Calculator
ifneq ($(WITH_GAPPS),true)
PRODUCT_PACKAGES += \
    ExactCalculator
endif

PRODUCT_PACKAGES += \
    nano_recovery

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mkfs.ntfs \
    mount.ntfs

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/fsck.ntfs \
    system/bin/mkfs.ntfs \
    system/bin/mount.ntfs \
    system/%/libfuse-lite.so \
    system/%/libntfs-3g.so

# Disable RescueParty due to high risk of data loss
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.disable_rescue=true

# FRP
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/wipe-frp.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/wipe-frp

# Gamespace
 PRODUCT_PACKAGES += \
     GameSpace
 
 PRODUCT_PRODUCT_PROPERTIES += \
     debug.graphics.game_default_frame_rate.disabled=true

# Gapps
ifeq ($(WITH_GAPPS),true)
include vendor/gms/gms_pico.mk

PRODUCT_PACKAGES += \
    UpdaterGMSOverlay
endif

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

# LMO
PRODUCT_PACKAGES += \
    LMOFreeform \
    LMOFreeformSidebar

# Overlays
include packages/overlays/Themes/themes.mk

# BTHelper
PRODUCT_PACKAGES += \
    BtHelper

# OmniJaws
PRODUCT_PACKAGES += \
    OmniJaws

# Props
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.debug.alloc=0 \
    ro.error.receiver.system.apps=com.google.android.gms \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.com.google.ime.theme_id=5 \
    ro.opa.eligible_device=true \
    ro.com.android.wifi-watchlist=GoogleGuest \
    drm.service.enabled=true \
    persist.sys.dun.override=0 \
    persist.sys.disable_rescue=true

PRODUCT_PRODUCT_PROPERTIES += \
    ro.input.video_enabled=false

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.arm64.memtag.app.com.android.se=off \
    persist.arm64.memtag.app.com.google.android.bluetooth=off \
    persist.arm64.memtag.app.com.android.nfc=off \
    persist.arm64.memtag.process.system_server=off \
    dalvik.vm.dex2oat64.enabled=true

# Face Unlock
ifeq ($(TARGET_SUPPORTS_64_BIT_APPS),true)
PRODUCT_PACKAGES += \
    FaceUnlock

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/android.hardware.biometrics.face.xml
endif

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# Default wifi country code
PRODUCT_SYSTEM_PROPERTIES += \
    ro.boot.wificountrycode?=00

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# Root
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    adb_root
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/xbin/su
endif
endif

# Disable touch video heatmap to reduce latency, motion jitter, and CPU usage
# on supported devices with Deep Press input classifier HALs and models
PRODUCT_PRODUCT_PROPERTIES += \
    ro.input.video_enabled=false

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    Launcher3QuickStep \
    Settings \
    CarSystemUI \
    SystemUI

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

ifneq ($(TARGET_BUILD_VARIANT),eng)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    debug.sf.enable_transaction_tracing=false
endif

# SetupWizard
ifeq ($(WITH_GAPPS),false)
PRODUCT_PRODUCT_PROPERTIES += \
    setupwizard.theme=glif_v4 \
    setupwizard.feature.day_night_mode_enabled=true
endif

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/infinity/overlay/no-rro
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/infinity/overlay/common \
    vendor/infinity/overlay/no-rro

PRODUCT_PACKAGES += \
    DocumentsUIOverlay \
    NetworkStackOverlay \
    NfcOverlay \
    PermissionControllerOverlay \
    CustomFontPixelLauncherOverlay

AXION_CPU_SMALL_CORES ?= 0,1,2,3
AXION_CPU_BIG_CORES ?= 4,5,6,7
AXION_CPU_UNLIMIT_UI ?= 0-7
AXION_CPU_BG ?= 0-2
AXION_CPU_FG ?= 0-7
AXION_CPU_LIMIT_BG ?= 0-1
AXION_CPU_LIMIT_UI ?= 0-4
AXION_CPU_DISPLAY ?= 4-7
AXION_CPU_AUDIO ?= 0-3

DEX2OAT_CORES ?= 0,1,2,3,4,5,6

# AxionOS properties
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.axion_cpu_big=$(AXION_CPU_BIG_CORES) \
    persist.sys.axion_cpu_small=$(AXION_CPU_SMALL_CORES) \
    persist.sys.axion_cpu_bg=$(AXION_CPU_BG) \
    persist.sys.axion_cpu_limit_bg=$(AXION_CPU_LIMIT_BG) \
    persist.sys.axion_cpu_fg=$(AXION_CPU_FG) \
    persist.sys.axion_cpu_limit_ui=$(AXION_CPU_LIMIT_UI) \
    persist.sys.axion_cpu_unlimit_ui=$(AXION_CPU_UNLIMIT_UI) \
    persist.sys.axion_cpu_audio=$(AXION_CPU_AUDIO) \
    persist.sys.axion_cpu_display=$(AXION_CPU_DISPLAY)

# dex2oat
PRODUCT_SYSTEM_PROPERTIES += \
    dalvik.vm.dex2oat-threads=6 \
    dalvik.vm.restore-dex2oat-threads=6 \
    dalvik.vm.dex2oat-cpu-set=$(DEX2OAT_CORES) \
    dalvik.vm.restore-dex2oat-cpu-set=$(DEX2OAT_CORES)

# Translations
CUSTOM_LOCALES += \
    ast_ES \
    gd_GB \
    cy_GB \
    fur_IT

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/crowdin/overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/crowdin/overlay

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/infinity/build/target/product/security/lineage

include vendor/infinity/config/version.mk

# Signing Keys
 ifeq ($(INFINITY_BUILD_TYPE),OFFICIAL)
 include vendor/infinity-priv/keys/keys.mk
 else
 -include vendor/infinity-priv/keys/keys.mk
 endif

-include $(WORKSPACE)/build_env/image-auto-bits.mk
