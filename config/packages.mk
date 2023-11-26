# GameSpace
PRODUCT_PACKAGES += \
    GameSpace \
    BatteryStatsViewer \
    ExactCalculator \
    OmniJaws

# Face Unlock
PRODUCT_PACKAGES += \
    FaceUnlock

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
