$(info "======= optee.mk enter =========")

LOADER_BIN := $(PRODUCT_OUT)/fip-loader-emmc.img
SECURE_BIN := $(PRODUCT_OUT)/fip-secure.img
NONSECURE_BIN := $(PRODUCT_OUT)/fip-nonsecure.img

# OPTEE BUILD
OPTEE_BL1_BIN := $(PRODUCT_OUT)/optee_bl1.bin
$(OPTEE_BL1_BIN): $(UBOOT_BIN)
	$(hide) echo "=========== OPTEE BL1 Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) clean
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-bl1

OPTEE_LLOADER := $(PRODUCT_OUT)/optee_lloader.bin
$(OPTEE_LLOADER): $(OPTEE_BL1_BIN)
	$(hide) echo "=========== OPTEE LLOADER Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-lloader

OPTEE_BL32_BIN := $(PRODUCT_OUT)/optee_bl32.bin
$(OPTEE_BL32_BIN): $(OPTEE_LLOADER)
	$(hide) echo "=========== OPTEE BL32 Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-bl32

# u-boot.bin dependency
OPTEE_FIP_BIN := $(PRODUCT_OUT)/optee_fip.bin
$(OPTEE_FIP_BIN): $(OPTEE_BL32_BIN) $(UBOOT_BIN)
	$(hide) echo "=========== OPTEE fip Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip

OPTEE_FIP_LOADER := $(PRODUCT_OUT)/optee_fip_loader.bin
$(OPTEE_FIP_LOADER): $(OPTEE_FIP_BIN)
	$(hide) echo "=========== OPTEE fip-loader Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip-loader

OPTEE_FIP_SECURE := $(PRODUCT_OUT)/optee_fip_secure.bin
$(OPTEE_FIP_SECURE): $(OPTEE_FIP_LOADER)
	$(hide) echo "=========== OPTEE fip-secure Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip-secure

OPTEE_FIP_NONSECURE := $(PRODUCT_OUT)/optee_fip_nonsecure.bin
$(OPTEE_FIP_NONSECURE): $(OPTEE_FIP_SECURE)
	$(hide) echo "=========== OPTEE fip-nonsecure Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip-nonsecure

OPTEE_SINGLEIMAGE := $(PRODUCT_OUT)/optee_singleimage.bin
$(OPTEE_SINGLEIMAGE): $(OPTEE_FIP_NONSECURE)
	$(hide) echo "=========== OPTEE single image Building !!! ==========="
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-singleimage

# generate image
$(NONSECURE_BIN): $(OPTEE_SINGLEIMAGE)
	echo >&2 echo "=========== Generate Image !!! ==========="; \
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader.bin \
		-o $(LOADER_BIN) \
		-l 0xbfcc0000 -e 0xbfd00800 \
		"-k 3 -m $(OFFSET_SECURE_HEAD) -b 3 -p 2 -m $(OFFSET_NONSECURE_HEAD) -b 3 -p 2";
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader.bin \
		-o $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader-sd.img \
		-l 0xbfcc0000 -e 0xbfd00800 \
		"-k 3 -m $(OFFSET_SECURE_HEAD) -b 3 -p 0 -m $(OFFSET_NONSECURE_HEAD) -b 3 -p 0";
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
	 	-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-secure.bin \
		-o $(SECURE_BIN) \
		-l 0xbfb00000 -e 0x00000000;
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-nonsecure.bin \
		-o $(NONSECURE_BIN) \
		-l 0xbdf00000 -e 0x00000000;
	fip_sec_size=$(shell stat --printf="%s" $(SECURE_BIN)); \
	fip_nonsec_size=$(shell stat --printf="%s" $(NONSECURE_BIN)); \
	echo >&2 "=========== fip_sec_size = $$fip_sec_size ==========="; \
	echo >&2 "=========== fip_nonsec_size = $$fip_nonsec_size ==========="; \
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader.bin \
		-o $(PRODUCT_OUT)/fip-loader-usb.img \
		-l 0xbfcc0000 -e 0xbfd00800 \
		"-k 0 -u -m 0xbfb00000 -z $(fip_sec_size) -m 0xbdf00000 -z $(fip_nonsec_size)";
	cat $(SECURE_BIN) >> $(PRODUCT_OUT)/fip-loader-usb.img
	cat $(NONSECURE_BIN) >> $(PRODUCT_OUT)/fip-loader-usb.img

.PHONY : $(NONSECURE_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(NONSECURE_BIN)

optee_image: $(NONSECURE_BIN)

$(info "======= optee.mk exit =========")
