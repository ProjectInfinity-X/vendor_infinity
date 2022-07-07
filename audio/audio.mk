# Copyright (C) 2020 The Proton AOSP Project
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

# Include Android 9 Material sounds instead of default AOSP ones
$(call inherit-product, frameworks/base/data/sounds/AudioPackage14.mk)

# 2019 Material product sounds (CC-BY 4.0)
# Source:  https://material.io/design/sound/sound-resources.html
LOCAL_PATH := vendor/infinity/audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/alarms/MorningAlarm.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/MorningAlarm.ogg \
    $(LOCAL_PATH)/notifications/Pikachu.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Pikachu.ogg \
    $(LOCAL_PATH)/ringtones/vibe.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/vibe.ogg
