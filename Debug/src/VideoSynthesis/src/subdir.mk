################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/VideoSynthesis/src/VideoSynthesis.cpp 

OBJS += \
./src/VideoSynthesis/src/VideoSynthesis.o 

CPP_DEPS += \
./src/VideoSynthesis/src/VideoSynthesis.d 


# Each subdirectory must supply rules for building sources it contributes
src/VideoSynthesis/src/%.o: ../src/VideoSynthesis/src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


