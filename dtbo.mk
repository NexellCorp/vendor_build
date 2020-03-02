# Copyright (C) 2018 The Android Open Source Project
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
$(info "======= dtbo.mk enter =========")

TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
KERNEL_CC_WRAPPER := $(CC_WRAPPER)
KERNEL_AFLAGS :=
KERNEL_CFLAGS :=

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin)
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin)
else
$(error kernel arch not supported at present)
endif

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/arm-linux-androidkernel-
KERNEL_SRC_ARCH := arm
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-
KERNEL_SRC_ARCH := arm64
else
$(error kernel arch not supported at present)
endif

# Use ccache if requested by USE_CCACHE variable
KERNEL_CROSS_COMPILE_WRAPPER := $(realpath $(KERNEL_CC_WRAPPER)) $(KERNEL_CROSS_COMPILE)

MKDTIMG := vendor/nexell/tools/mkdtimg

define build_dtb
	CCACHE_NODIRECT="true" $(MAKE) -C $(TARGET_KERNEL_SRC) \
	O=$(realpath $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ) \
	ARCH=$(KERNEL_ARCH) \
	CROSS_COMPILE="$(KERNEL_CROSS_COMPILE_WRAPPER)" \
	KCFLAGS="$(KERNEL_CFLAGS)" \
	KAFLAGS="$(KERNEL_AFLAGS)" \
	dtbs
endef

$(BOARD_PREBUILT_DTBOIMAGE): $(KERNEL_BIN) $(MKDTIMG)
	$(hide) echo "Building $(KERNEL_ARCH) dtbo."
	$(hide) PATH=$$PATH $(MAKE) -C $(TARGET_KERNEL_SRC) mrproper
	$(call build_dtb)
	#$(hide) echo "DTIMG_ARG: $(DTIMG_ARG) ..."
	#$(hide) echo " $(MKDTIMG) create $(BOARD_DTBOIMAGE) $(DTIMG_ARG) "
	$(MKDTIMG) create $(BOARD_PREBUILT_DTBOIMAGE) "$(DTIMG_ARG)"
	$(shell cp -af $(BOARD_PREBUILT_DTBOIMAGE) $(PRODUCT_OUT)/dtbo.img )

.PHONY: dtboimage
dtboimage: $(BOARD_PREBUILT_DTBOIMAGE)

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_PREBUILT_DTBOIMAGE)

$(info "======= dtbo.mk exit =========")
