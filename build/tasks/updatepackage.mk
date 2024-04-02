# Copyright (C) 2022 PixysOS Project
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
# SuperiorOS OTA update package

INFINITY_TARGET_UPDATEPACKAGE := $(PRODUCT_OUT)/$(INFINITY_VERSION)-updateimages.zip

.PHONY: updatepackage
updatepackage: $(INTERNAL_UPDATE_PACKAGE_TARGET)
	$(hide) ln -f $(INTERNAL_UPDATE_PACKAGE_TARGET) $(INFINITY_TARGET_UPDATEPACKAGE)
	@echo ""
	@echo ""
	@echo "**************************************************"
	@echo " OTA update package is ready: $(INFINITY_TARGET_UPDATEPACKAGE)"
	@echo "**************************************************"
	@echo ""
