# Copyright (C) 2017 Unlegacy-Android
# Copyright (C) 2017,2020 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------
# INFINITY OTA update package

INFINITY_TARGET_PACKAGE := $(PRODUCT_OUT)/$(INFINITY_VERSION).zip

SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

.PHONY: bacon
bacon: $(BUILT_TARGET_FILES_PACKAGE) $(INTERNAL_OTA_PACKAGE_TARGET)
	$(hide) mv $(INTERNAL_OTA_PACKAGE_TARGET) $(INFINITY_TARGET_PACKAGE)
	$(hide) ./vendor/infinity/build/tools/generate_ota_info.sh $(INFINITY_TARGET_PACKAGE)
	echo -e ${CL_BLD}${CL_RED}"===============================-Package complete-==============================="${CL_RED}
	echo -e ${CL_BLD}${CL_GRN}"Get your Compiled ROM Package from: "${CL_RED} $(INFINITY_TARGET_PACKAGE)${CL_RST}
	echo " "
	echo -e ${CL_BLD}${CL_GRN}"Get your Compiled ROM Package's ota json from: "${CL_RED} $(INFINITY_TARGET_PACKAGE).json${CL_RST}
	echo " "
	echo " "
	echo -e ${CL_BLD}${CL_RED}"                    Thanks for showing interest in Project Infinity-X ❤️"${CL_RED}
	echo " "
	echo -e ${CL_BLD}${CL_RED}"================================================================================"${CL_RED}
