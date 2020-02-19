$(info "======= uboot.mk enter =========")

# Check target arch.
TARGET_UBOOT_ARCH := $(strip $(TARGET_ARCH))
UBOOT_ARCH := $(TARGET_UBOOT_ARCH)
UBOOT_CC_WRAPPER := $(CC_WRAPPER)

# Toolchain ABS
ifeq ($(TARGET_UBOOT_ARCH), arm)
UBOOT_TOOLCHAIN_EABI := $(realpath vendor/nexell/toolchain/arm-eabi-4.8/bin)
endif

# Cross Compile
ifeq ($(TARGET_UBOOT_ARCH), arm)
UBOOT_CROSS_COMPILE := $(UBOOT_TOOLCHAIN_EABI)/arm-eabi-
UBOOT_SRC_ARCH := arm
UBOOT_CFLAGS :=
endif

# Allow caller to override toolchain.
TARGET_UBOOT_CROSS_COMPILE_PREFIX := $(strip $(TARGET_UBOOT_CROSS_COMPILE_PREFIX))
ifneq ($(TARGET_UBOOT_CROSS_COMPILE_PREFIX),)
UBOOT_CROSS_COMPILE := $(TARGET_UBOOT_CROSS_COMPILE_PREFIX)
endif

# Use ccache if requested by USE_CCACHE variable
UBOOT_CROSS_COMPILE_WRAPPER := $(realpath $(UBOOT_CC_WRAPPER)) $(UBOOT_CROSS_COMPILE)

TARGET_UBOOT_BUILD_TARGET=bootloader.img

UBOOT_BIN := $(PRODUCT_OUT)/$(TARGET_UBOOT_BUILD_TARGET)
UBOOT_DIR := $(TARGET_UBOOT_SRC)

# UBOOT Build
$(UBOOT_BIN):
	$(hide) echo "=========== (4/5) U-BOOT Building !!! =========="
	$(hide) echo "=========== CROSS_COMPILE : $(UBOOT_CROSS_COMPILE_WRAPPER) =========="
	$(MAKE) -C $(UBOOT_DIR) distclean;
	$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE="$(UBOOT_CROSS_COMPILE_WRAPPER)"  $(UBOOT_CONFIG);
	$(MAKE) -C $(UBOOT_DIR) CROSS_COMPILE="$(UBOOT_CROSS_COMPILE_WRAPPER)" ;
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot -i $(UBOOT_DIR)/u-boot.bin -o \
		$(UBOOT_BIN) -l $(UBOOT_IMG_LOAD_ADDR) -e $(UBOOT_IMG_JUMP_ADDR);

.PHONY : $(UBOOT_BIN)

bootloader: $(UBOOT_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(UBOOT_BIN)

$(info "======= uboot.mk exit =========")
