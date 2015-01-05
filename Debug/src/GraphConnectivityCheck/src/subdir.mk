################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/GraphConnectivityCheck/src/GraphConnectivityCheck.cpp 

OBJS += \
./src/GraphConnectivityCheck/src/GraphConnectivityCheck.o 

CPP_DEPS += \
./src/GraphConnectivityCheck/src/GraphConnectivityCheck.d 


# Each subdirectory must supply rules for building sources it contributes
src/GraphConnectivityCheck/src/%.o: ../src/GraphConnectivityCheck/src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


