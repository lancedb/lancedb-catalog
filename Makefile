
VERSION = 0.0.1

gen-rust-reqwest-client:
	openapi-generator generate \
	  -i ./spec/catalog.yaml \
	  -g rust \
	  -o ./rust/lance-catalog-reqwest-client \
	  --additional-properties=packageName=lance-catalog-client,packageVersion=$(VERSION),asyncApi=true,library=reqwest

gen-java-apache-client:
	openapi-generator generate \
	  -i ./spec/catalog.yaml \
	  -g java \
	  -o ./java/lance-catalog-apache-client \
	  --ignore-file-override=java/.apache-client-ignore \
	  --additional-properties=groupId=com.lancedb,artifactId=lance-catalog-apache-client,artifactVersion=$(VERSION),parentGroupId=com.lancedb,parentArtifactId=lance-catalog-root,parentVersion=$(VERSION),parentRelativePath=./java/pom.xml,library=apache-httpclient,apiPackage=com.lancedb.lance.catalog.client.apache.api,modelPackage=com.lancedb.lance.catalog.client.apache.model,hideGenerationTimestamp=true,licenseName=Apache-2.0,licenseUrl=https://www.apache.org/licenses/LICENSE-2.0.txt
	sed -i '' -e 's#<junit-version>5.10.2</junit-version>#<junit-version>5.8.2</junit-version>#g' java/lance-catalog-apache-client/pom.xml

gen-java-springboot-server:
	openapi-generator generate \
	  -i ./spec/catalog.yaml \
	  -g spring \
      -o ./java/lance-catalog-springboot-server \
      --additional-properties=groupId=com.lancedb,artifactId=lance-catalog-springboot-server,artifactVersion=$(VERSION),parentGroupId=com.lancedb,parentArtifactId=lance-catalog-root,parentVersion=$(VERSION),parentRelativePath=./java/pom.xml,library=spring-boot,interfaceOnly=true,useOptional=true,openApiNullable=false,java8=true,apiPackage=com.lancedb.lance.catalog.server.springboot.api,modelPackage=com.lancedb.lance.catalog.server.springboot.model,useTags=true,skipDefaultInterface=false,hideGenerationTimestamp=true,licenseName=Apache-2.0,licenseUrl=https://www.apache.org/licenses/LICENSE-2.0.txt