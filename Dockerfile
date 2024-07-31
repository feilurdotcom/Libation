# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Copy the source code into the container
COPY Source /Source

# Set the target platform and runtime identifier based on TARGETPLATFORM
ARG TARGETPLATFORM
RUN set -eux; \
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        RID="linux-x64"; \
        echo "Check amd64: ${TARGETPLATFORM}"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
        RID="linux-arm64"; \
        echo "Check arm64: ${TARGETPLATFORM}"; \
    else \
        echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1; \
    fi; \
    echo "Building for RID: ${RID}"; \
    dotnet publish -c Release -r ${RID} --self-contained -o /Source/bin/Publish/Linux-chardonnay /Source/LibationCli/LibationCli.csproj

# Use the .NET Runtime image for running the application
FROM mcr.microsoft.com/dotnet/runtime:8.0

# Set environment variables
ENV SLEEP_TIME "30m"
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Create necessary directories
RUN mkdir /db /config /data

# Copy the published output from the build stage
COPY --from=build-env /Source/bin/Publish/Linux-chardonnay /libation

# Ensure the binary is executable
RUN chmod +x /libation/LibationCli

# Set the command to run the application
CMD ["./libation/liberate.sh"]
