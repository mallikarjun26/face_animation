################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/CLASS_facepipe_VJ_29-Sep-08b/facedet/OpenCV_ViolaJones/OpenCV_ViolaJones.cpp 

OBJS += \
./src/CLASS_facepipe_VJ_29-Sep-08b/facedet/OpenCV_ViolaJones/OpenCV_ViolaJones.o 

CPP_DEPS += \
./src/CLASS_facepipe_VJ_29-Sep-08b/facedet/OpenCV_ViolaJones/OpenCV_ViolaJones.d 


# Each subdirectory must supply rules for building sources it contributes
src/CLASS_facepipe_VJ_29-Sep-08b/facedet/OpenCV_ViolaJones/%.o: ../src/CLASS_facepipe_VJ_29-Sep-08b/facedet/OpenCV_ViolaJones/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


