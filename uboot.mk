$(info "======= uboot.mk enter =========")

# Check target arch.
UBOOT_ARCH := $(TARGET_UBOOT_ARCH)
UBOOT_CC_WRAPPER := $(CC_WRAPPER)

# Toolchain ABS
ifeq ($(TARGET_UBOOT_ARCH), arm)
UBOOT_TOOLCHAIN_EABI := $(realpath vendor/nexell/toolchain/arm-eabi-4.8/bin)
else
UBOOT_TOOLCHAIN_EABI := $(realpath prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin)
endif

# Cross Compile
ifeq ($(TARGET_UBOOT_ARCH), arm)
UBOOT_CROSS_COMPILE := $(UBOOT_TOOLCHAIN_EABI)/arm-eabi-
UBOOT_SRC_ARCH := arm
UBOOT_CFLAGS :=
else
UBOOT_CROSS_COMPILE := $(UBOOT_TOOLCHAIN_EABI)/aarch64-linux-android-
UBOOT_SRC_ARCH := arm64
UBOOT_CFLAGS :=
endif

# Allow caller to override toolchain.
TARGET_UBOOT_CROSS_COMPILE_PREFIX := $(strip $(TARGET_UBOOT_CROSS_COMPILE_PREFIX))
ifneq ($(TARGET_UBOOT_CROSS_COMPILE_PREFIX),)
UBOOT_CROSS_COMPILE := $(TARGET_UBOOT_CROSS_COMPILE_PREFIX)
endif

# Use ccache if requested by USE_CCACHE variable
UBOOT_CROSS_COMPILE_WRAPPER := $(realpath $(UBOOT_CC_WRAPPER)) $(UBOOT_CROSS_COMPILE)


UBOOT_DIR := $(TARGET_UBOOT_SRC)
UBOOT_BIN := $(UBOOT_DIR)/u-boot.bin
NONSECURE_BIN := $(PRODUCT_OUT)/uboot.img
PARAM_BIN := $(PRODUCT_OUT)/params.bin

ifeq ($(TARGET_UBOOT_ARCH), arm)
$(NONSECURE_BIN) : $(UBOOT_BIN)
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot -i $(UBOOT_BIN) -o \
		$(NONSECURE_BIN) -l $(UBOOT_IMG_LOAD_ADDR) -e $(UBOOT_IMG_JUMP_ADDR);
endif

# UBOOT Build
$(UBOOT_BIN):
	$(hide) echo "=========== U-BOOT Building !!! =========="
	$(hide) echo "=========== CROSS_COMPILE : $(UBOOT_CROSS_COMPILE_WRAPPER) =========="
	$(MAKE) -C $(UBOOT_DIR) distclean;
	$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE="$(UBOOT_CROSS_COMPILE_WRAPPER)"  $(UBOOT_CONFIG);
	$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE="$(UBOOT_CROSS_COMPILE_WRAPPER)" ;
#ifeq ($(TARGET_UBOOT_ARCH), arm)
#	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot -i $(UBOOT_BIN) -o \
#		$(NONSECURE_BIN) -l $(UBOOT_IMG_LOAD_ADDR) -e $(UBOOT_IMG_JUMP_ADDR);
#endif
	$(UBOOT_CROSS_COMPILE)objcopy -O binary --only-section=.rodata.default_environment $(UBOOT_DIR)/common/env_common.o
	tr '\0' '\n' < $(UBOOT_DIR)/common/env_common.o > $(PRODUCT_OUT)/default_envs.txt;
	echo "bootcmd_a=${BOOTCMD_A}" >> $(PRODUCT_OUT)/default_envs.txt
	echo "bootcmd_b=${BOOTCMD_B}" >> $(PRODUCT_OUT)/default_envs.txt
	echo "recovery_bootcmd_a=${RECOVERY_BOOTCMD_A}" >> $(PRODUCT_OUT)/default_envs.txt
	echo "recovery_bootcmd_b=${RECOVERY_BOOTCMD_B}" >> $(PRODUCT_OUT)/default_envs.txt
	echo "nxquickrear_args_0=${NXQUICKREAR_ARGS_0}" >> $(PRODUCT_OUT)/default_envs.txt
	echo "nxquickrear_args_1=${NXQUICKREAR_ARGS_1}" >> $(PRODUCT_OUT)/default_envs.txt
	# bootargs replace
	sed -i -e 's/bootargs=.*/bootargs='"${UBOOT_BOOTARGS}"'/g' $(PRODUCT_OUT)/default_envs.txt
	sed -i -e 's/splashsource=.*/splashsource='"${SPLASH_SOURCE}"'/g' $(PRODUCT_OUT)/default_envs.txt
	sed -i -e 's/splashoffset=.*/splashoffset='"${SPLASH_OFFSET}"'/g' $(PRODUCT_OUT)/default_envs.txt
	echo "recovery_bootargs=${UBOOT_RECOVERY_BOOTARGS}" >> $(PRODUCT_OUT)/default_envs.txt
	$(UBOOT_DIR)/tools/mkenvimage -s 16384 -o $(PARAM_BIN) $(PRODUCT_OUT)/default_envs.txt

.PHONY : $(UBOOT_BIN)

uboot_img: $(UBOOT_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(UBOOT_BIN)

$(info "======= uboot.mk exit =========")
