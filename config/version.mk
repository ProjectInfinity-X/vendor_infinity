# Copyright (C) 2024 Project Infinity X
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

ANDROID_VERSION := 15
INFINITYVERSION := 2.2

INFINITY_BUILD_TYPE ?= UNOFFICIAL
INFINITY_MAINTAINER ?= UNKNOWN
INFINITY_DATE_YEAR := $(shell date -u +%Y)
INFINITY_DATE_MONTH := $(shell date -u +%m)
INFINITY_DATE_DAY := $(shell date -u +%d)
INFINITY_DATE_HOUR := $(shell date -u +%H)
INFINITY_DATE_MINUTE := $(shell date -u +%M)
INFINITY_BUILD_DATE := $(INFINITY_DATE_YEAR)$(INFINITY_DATE_MONTH)$(INFINITY_DATE_DAY)-$(INFINITY_DATE_HOUR)$(INFINITY_DATE_MINUTE)
TARGET_PRODUCT_SHORT := $(subst infinity_,,$(INFINITY_BUILD))

# OFFICIAL_DEVICES
ifeq ($(INFINITY_BUILD_TYPE), OFFICIAL)
  LIST = $(shell cat vendor/infinity/infinity.devices)
    ifeq ($(filter $(INFINITY_BUILD), $(LIST)), $(INFINITY_BUILD))
      IS_OFFICIAL=true
      INFINITY_BUILD_TYPE := OFFICIAL
    endif
    ifneq ($(IS_OFFICIAL), true)
      INFINITY_BUILD_TYPE := UNOFFICIAL
      $(error Device is not official "$(INFINITY_BUILD)")
    endif
endif

INFINITY_VERSION := Project_Infinity-X-$(INFINITYVERSION)-$(INFINITY_BUILD)-$(INFINITY_BUILD_DATE)-VANILLA-$(INFINITY_BUILD_TYPE)
ifeq ($(WITH_GAPPS), true)
INFINITY_VERSION := Project_Infinity-X-$(INFINITYVERSION)-$(INFINITY_BUILD)-$(INFINITY_BUILD_DATE)-GAPPS-$(INFINITY_BUILD_TYPE)
endif
INFINITY_MOD_VERSION :=$(ANDROID_VERSION)-$(INFINITYVERSION)
INFINITY_DISPLAY_VERSION := Project_Infinity-X-$(INFINITYVERSION)-$(INFINITY_BUILD_TYPE)
INFINITY_DISPLAY_BUILDTYPE := $(INFINITY_BUILD_TYPE)
INFINITY_FINGERPRINT := Project_Infinity/$(INFINITY_MOD_VERSION)/$(TARGET_PRODUCT_SHORT)/$(INFINITY_BUILD_DATE)

# INFINITY System Version
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
  ro.infinity.build.version=$(INFINITY_VERSION) \
  ro.infinity.build.status=$(INFINITY_BUILD_TYPE) \
  ro.modversion=$(INFINITY_MOD_VERSION) \
  ro.infinity.build.date=$(INFINITY_BUILD_DATE) \
  ro.infinity.buildtype=$(INFINITY_BUILD_TYPE) \
  ro.infinity.fingerprint=$(INFINITY_FINGERPRINT) \
  ro.infinity.device=$(INFINITY_BUILD) \
  ro.infinity.version=$(INFINITYVERSION) \
  ro.infinity.maintainer=$(INFINITY_MAINTAINER)
