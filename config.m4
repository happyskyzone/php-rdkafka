dnl $Id$
dnl config.m4 for extension rdkafka

PHP_ARG_WITH(rdkafka, for rdkafka support,
[  --with-rdkafka             Include rdkafka support])

if test "$PHP_RDKAFKA" != "no"; then

  SEARCH_PATH="/usr/local /usr"     # you might want to change this
  SEARCH_FOR="/include/librdkafka/rdkafka.h"  # you most likely want to change this
  if test -r $PHP_RDKAFKA/$SEARCH_FOR; then # path given as parameter
    RDKAFKA_DIR=$PHP_RDKAFKA
  else # search default path list
    AC_MSG_CHECKING([for librdkafka/rdkafka.h" in default path])
    for i in $SEARCH_PATH ; do
      if test -r $i/$SEARCH_FOR; then
        RDKAFKA_DIR=$i
        AC_MSG_RESULT(found in $i)
      fi
    done
  fi
  
  if test -z "$RDKAFKA_DIR"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Please reinstall the rdkafka distribution])
  fi

  PHP_ADD_INCLUDE($RDKAFKA_DIR/include)

  LIBNAME=rdkafka
  LIBSYMBOL=rd_kafka_new

  PHP_CHECK_LIBRARY($LIBNAME,$LIBSYMBOL,
  [
    PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $RDKAFKA_DIR/$PHP_LIBDIR, RDKAFKA_SHARED_LIBADD)
    AC_DEFINE(HAVE_RDKAFKALIB,1,[ ])
  ],[
    AC_MSG_ERROR([wrong rdkafka lib version or lib not found])
  ],[
    -L$RDKAFKA_DIR/$PHP_LIBDIR -lm
  ])

  AC_CHECK_LIB($LIBNAME,[rd_kafka_msg_partitioner_consistent],[
    AC_DEFINE(HAVE_RD_KAFKA_MSG_PARTIIONER_CONSISTENT,1,[ ])
  ],[
    AC_MSG_WARN([no rd_kafka_msg_partitioner_consistent, the consistent partitioner will not be available])
  ])
  
  PHP_SUBST(RDKAFKA_SHARED_LIBADD)

  PHP_NEW_EXTENSION(rdkafka, rdkafka.c metadata.c metadata_broker.c metadata_topic.c metadata_partition.c metadata_collection.c compat.c, $ext_shared)
fi
