$(info "======= optee.mk enter =========")

LOADER_BIN := $(PRODUCT_OUT)/fip-loader-emmc.img
SECURE_BIN := $(PRODUCT_OUT)/fip-secure.img
NONSECURE_BIN := $(PRODUCT_OUT)/fip-nonsecure.img


# generate image
$(NONSECURE_BIN): $(UBOOT_BIN)
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) clean
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-bl1
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-lloader
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-bl32
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip-loader
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip-secure
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-fip-nonsecure
	$(MAKE) -C $(TARGET_OPTEE_SRC) $(OPTEE_BUILD_OPT) build-singleimage
	echo $(OPTEE_BUILD_OPT)
	echo >&2 echo "=========== Generate Image !!! ==========="; \
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader.bin \
		-o $(LOADER_BIN) \
		-l 0xbfcc0000 -e 0xbfd00800 \
		-k 3 -m $(OFFSET_SECURE_HEAD) -b 3 -p 2 \
		-m $(OFFSET_NONSECURE_HEAD) -b 3 -p 2;
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader.bin \
		-o $(TARGET_OPTEE_SRC)/optee_build/result/fip-loader-sd.img \
		-l 0xbfcc0000 -e 0xbfd00800 \
		-k 3 -m $(OFFSET_SECURE_HEAD) -b 3 -p 0 \
		-m $(OFFSET_NONSECURE_HEAD) -b 3 -p 0
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
	 	-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-secure.bin \
		-o $(SECURE_BIN) \
		-l 0xbfb00000 -e 0x00000000;
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot \
		-i $(TARGET_OPTEE_SRC)/optee_build/result/fip-nonsecure.bin \
		-o $(NONSECURE_BIN) \
		-l 0xbdf00000 -e 0x00000000;
	vendor/nexell/tools/gen_fip_loader.sh \
		$(SOC_NAME) \
		$(SECURE_BIN) \
		$(NONSECURE_BIN) \
		$(TARGET_OPTEE_SRC)/optee_build/result/fip-loader.bin \
		$(PRODUCT_OUT)/fip-loader-usb.img
	cat $(SECURE_BIN) >> $(PRODUCT_OUT)/fip-loader-usb.img
	cat $(NONSECURE_BIN) >> $(PRODUCT_OUT)/fip-loader-usb.img

.PHONY : $(NONSECURE_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(NONSECURE_BIN)

optee_image: $(NONSECURE_BIN)

$(info "======= optee.mk exit =========")
