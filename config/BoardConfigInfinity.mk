include vendor/infinity/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/infinity/config/BoardConfigQcom.mk
endif

include vendor/infinity/config/BoardConfigSoong.mk
