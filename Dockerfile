# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Set the target platform and runtime identifier based on TARGETPLATFORM
ARG TARGETPLATFORM
RUN set -eux; \
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        export RID="linux-x64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
        export RID="linux-arm64"; \
    else \
        echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1; \
    fi && \
    echo "Building for RID: ${RID}"

# Copy the source code into the container
COPY Source /Source

# Publish the application for the target runtime identifier (RID)
RUN if [ "${RID}" ]; then \
        dotnet publish -c Release -o /Source/bin/Publish/Linux-chardonnay /Source/LibationCli/LibationCli.csproj -r ${RID} --self-contained; \
    else \
        dotnet publish -c Release -o /Source/bin/Publish/Linux-chardonnay /Source/LibationCli/LibationCli.csproj --self-contained; \
    fi

# Copy the script into the published output directory
COPY Docker/liberate.sh /Source/bin/Publish/Linux-chardonnay

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

# Set the command to run the application
CMD ["./libation/liberate.sh"]
