################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/EdgeWeightTransform/src/EdgeWeightTransform.cpp 

OBJS += \
./src/EdgeWeightTransform/src/EdgeWeightTransform.o 

CPP_DEPS += \
./src/EdgeWeightTransform/src/EdgeWeightTransform.d 


# Each subdirectory must supply rules for building sources it contributes
src/EdgeWeightTransform/src/%.o: ../src/EdgeWeightTransform/src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


