################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/MEX\ Testing/GetEdgeWeights/getEdgeWeights.cpp 

OBJS += \
./src/MEX\ Testing/GetEdgeWeights/getEdgeWeights.o 

CPP_DEPS += \
./src/MEX\ Testing/GetEdgeWeights/getEdgeWeights.d 


# Each subdirectory must supply rules for building sources it contributes
src/MEX\ Testing/GetEdgeWeights/getEdgeWeights.o: ../src/MEX\ Testing/GetEdgeWeights/getEdgeWeights.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"src/MEX Testing/GetEdgeWeights/getEdgeWeights.d" -MT"src/MEX\ Testing/GetEdgeWeights/getEdgeWeights.d" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


