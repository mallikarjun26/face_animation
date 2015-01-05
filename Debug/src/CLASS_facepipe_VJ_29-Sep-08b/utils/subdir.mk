################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CXX_SRCS += \
../src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_disttransform.cxx \
../src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_haarcascade_masked.cxx \
../src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_intimg_cols.cxx \
../src/CLASS_facepipe_VJ_29-Sep-08b/utils/vgg_interp2.cxx 

OBJS += \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_disttransform.o \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_haarcascade_masked.o \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_intimg_cols.o \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/vgg_interp2.o 

CXX_DEPS += \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_disttransform.d \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_haarcascade_masked.d \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/mre_intimg_cols.d \
./src/CLASS_facepipe_VJ_29-Sep-08b/utils/vgg_interp2.d 


# Each subdirectory must supply rules for building sources it contributes
src/CLASS_facepipe_VJ_29-Sep-08b/utils/%.o: ../src/CLASS_facepipe_VJ_29-Sep-08b/utils/%.cxx
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


