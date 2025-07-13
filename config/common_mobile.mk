# Inherit common mobile Lineage stuff
$(call inherit-product, vendor/infinity/config/common.mk)

# Include AOSP audio files
$(call inherit-product-if-exists, frameworks/base/data/sounds/AudioPackage14.mk)
include vendor/infinity/config/aosp_audio.mk

# Include Lineage audio files
include vendor/infinity/config/lineage_audio.mk

# Apps
PRODUCT_PACKAGES += \
    AvatarPicker \
    Glimpse \
    LatinIME

# Media
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    media.recorder.show_manufacturer_and_model=true

# Display
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    debug.sf.frame_rate_multiple_threshold=60

# SystemUI plugins
PRODUCT_PACKAGES += \
    QuickAccessWallet

# TextClassifier
PRODUCT_PACKAGES += \
    libtextclassifier_annotator_en_model \
    libtextclassifier_annotator_universal_model \
    libtextclassifier_actions_suggestions_universal_model \
    libtextclassifier_lang_id_model

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/textclassifier/actions_suggestions.universal.model \
    system/etc/textclassifier/lang_id.model \
    system/etc/textclassifier/textclassifier.en.model \
    system/etc/textclassifier/textclassifier.universal.model

# Themes
PRODUCT_PACKAGES += \
    ThemePicker \
    ThemesStub
