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
# Infinity OTA update package
INFINITY_TARGET_PACKAGE := $(PRODUCT_OUT)/$(ZIP_NAME).zip

SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

$(INFINITY_TARGET_PACKAGE): $(INTERNAL_OTA_PACKAGE_TARGET)
	$(hide) mv -f $(INTERNAL_OTA_PACKAGE_TARGET) $(INFINITY_TARGET_PACKAGE)
	$(hide) ./vendor/infinity/build/tools/generate_ota_info.sh $(INFINITY_TARGET_PACKAGE)
	@echo -e "" >&2
	@echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" >&2
	@echo -e "" >&2
	@echo -e "\033[1;34m    ██╗███╗   ██╗███████╗██╗███╗   ██╗██╗████████╗██╗   ██╗    ██╗  ██╗\033[0m" >&2
	@echo -e "\033[1;34m    ██║████╗  ██║██╔════╝██║████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝    ╚██╗██╔╝\033[0m" >&2
	@echo -e "\033[1;34m    ██║██╔██╗ ██║█████╗  ██║██╔██╗ ██║██║   ██║    ╚████╔╝      ╚███╔╝\033[0m" >&2
	@echo -e "\033[1;34m    ██║██║╚██╗██║██╔══╝  ██║██║╚██╗██║██║   ██║     ╚██╔╝       ██╔██╗\033[0m" >&2
	@echo -e "\033[1;34m    ██║██║ ╚████║██║     ██║██║ ╚████║██║   ██║      ██║       ██╔╝ ██╗\033[0m" >&2
	@echo -e "\033[1;34m    ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝       ╚═╝  ╚═╝\033[0m" >&2
	@echo -e "" >&2
	@echo -e "\033[1;34m                      ✨ BUILD COMPILED SUCCESSFULLY ✨\033[0m" >&2
	@echo -e "" >&2
	@echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" >&2
	@echo -e "" >&2
	@echo -e "\033[1;37m  ▸ Package:\033[0m    \033[1;37m$(notdir $(INFINITY_TARGET_PACKAGE))\033[0m" >&2
	@echo -e "\033[1;37m  ▸ Device:\033[0m     \033[1;37m$$(grep -m1 'ro.infinity.device=' $(PRODUCT_OUT)/system/build.prop 2>/dev/null | cut -d'=' -f2)\033[0m" >&2
	@echo -e "\033[1;37m  ▸ Variant:\033[0m    \033[1;37m$(TARGET_BUILD_VARIANT)\033[0m" >&2
	@echo -e "\033[1;37m  ▸ Size:\033[0m       \033[1;37m$(shell du -h $(INFINITY_TARGET_PACKAGE) | cut -f1)\033[0m" >&2
	@echo -e "" >&2
	@echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" >&2
	@echo -e "" >&2
	@echo -e "" >&2
	@echo -e "\033[1;37m              Thanks for compiling Project Infinity X ❤️\033[0m" >&2
	@echo -e "\033[1;34m             ────────────────────────────────────────────\033[0m" >&2
	@echo -e "" >&2

.PHONY: bacon
bacon: $(INFINITY_TARGET_PACKAGE) $(DEFAULT_GOAL)