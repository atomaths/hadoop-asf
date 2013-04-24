SNAPPY_VERSION=1.0.5
PROTOBUF_VERSION=2.4.1
HADOOP_VERSION=2.0.3-alpha-src

DIR=`dirname "$0"`
BUILD_HOME=`cd "$DIR"; pwd`

cd $BUILD_HOME
echo "Fetching snappy"
wget http://snappy.googlecode.com/files/snappy-${SNAPPY_VERSION}.tar.gz
tar xzf snappy-${SNAPPY_VERSION}.tar.gz
rm snappy-${SNAPPY_VERSION}.tar.gz

cd $BUILD_HOME/snappy-${SNAPPY_VERSION}
./configure --with-pic --prefix=$BUILD_HOME/snappy-${SNAPPY_VERSION}/build
make install


cd $BUILD_HOME
echo "Fetching protocol buffer"
wget https://protobuf.googlecode.com/files/protobuf-${PROTOBUF_VERSION}.tar.gz
tar xzf protobuf-${PROTOBUF_VERSION}.tar.gz
rm protobuf-${PROTOBUF_VERSION}.tar.gz

cd $BUILD_HOME/protobuf-${PROTOBUF_VERSION}
./configure --prefix=$BUILD_HOME/protobuf-${PROTOBUF_VERSION}/build
make install
export PATH=$BUILD_HOME/protobuf-${PROTOBUF_VERSION}/build/bin:$PATH
alias protoc=$BUILD_HOME/protobuf-${PROTOBUF_VERSION}/build/bin/protoc

cd $BUILD_HOME
rm -rf hadoop-${HADOOP_VERSION}
tar xzf hadoop-${HADOOP_VERSION}.tar.gz
cd $BUILD_HOME/hadoop-${HADOOP_VERSION}

for PATCH in `ls -1 $BUILD_HOME/patch/* | sort` ; do
    if [ -s $PATCH ]; then
        patch -p0 -i $PATCH
    fi
done

echo "Build hadoop"
mvn  install -Pnative -Pdist -DskipTests=true \
    -Dbundle.snappy=true -Drequire.snappy=true \
    -Dsnappy.prefix=$BUILD_HOME/snappy-${SNAPPY_VERSION}/build/lib \
    -Dsnappy.lib=$BUILD_HOME/snappy-${SNAPPY_VERSION}/build/lib \
    -Dsnappy.include=$BUILD_HOME/snappy-${SNAPPY_VERSION}
