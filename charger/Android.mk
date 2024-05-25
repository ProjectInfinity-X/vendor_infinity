#
# Copyright (C) 2024 The InfinityX Project
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
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_battery_scale
LOCAL_MODULE_STEM := battery_scale.png
LOCAL_SRC_FILES := images/charger/battery_scale.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_battery_scale_vendor
LOCAL_MODULE_STEM := battery_scale.png
LOCAL_SRC_FILES := images/charger/battery_scale.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_battery_fail
LOCAL_MODULE_STEM := battery_fail.png
LOCAL_SRC_FILES := images/charger/battery_fail.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_battery_fail_vendor
LOCAL_MODULE_STEM := battery_fail.png
LOCAL_SRC_FILES := images/charger/battery_fail.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_font
LOCAL_MODULE_STEM := main_font.png
LOCAL_SRC_FILES := images/charger/main_font.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_font_vendor
LOCAL_MODULE_STEM := main_font.png
LOCAL_SRC_FILES := images/charger/main_font.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_animation
LOCAL_MODULE_STEM := animation.txt
LOCAL_SRC_FILES := values/charger/animation.txt
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/values/charger
LOCAL_REQUIRED_MODULES := infinity_charger_battery_scale infinity_charger_battery_fail infinity_charger_font
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := infinity_charger_animation_vendor
LOCAL_MODULE_STEM := animation.txt
LOCAL_SRC_FILES := values/charger/animation.txt
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/values/charger
LOCAL_REQUIRED_MODULES := infinity_charger_battery_scale_vendor infinity_charger_battery_fail_vendor infinity_charger_font_vendor
include $(BUILD_PREBUILT)
