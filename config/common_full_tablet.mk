# Inherit mobile full common Lineage stuff
$(call inherit-product, vendor/infinity/config/common_mobile_full.mk)

# Inherit tablet common Lineage stuff
$(call inherit-product, vendor/infinity/config/tablet.mk)

$(call inherit-product, vendor/infinity/config/telephony.mk)
