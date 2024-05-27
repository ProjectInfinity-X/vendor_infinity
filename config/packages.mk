# GameSpace
PRODUCT_PACKAGES += \
    GameSpace \
    BatteryStatsViewer \
    ExactCalculator \
    OmniJaws \
    OmniStyle

# Face Unlock
PRODUCT_PACKAGES += \
    FaceUnlock

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml

# Lineage Health
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/org.lineageos.health.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.health.xml
