sudo docker network create reservierung
sudo docker-compose up -d

i=1
while [[ $i -le $1 ]]
do
    sudo docker run --name customermanagementserver$i --hostname=customermanagementserver$i --net-alias=customermanagementserver  --net=reservierung -e CLUSTERED=true -e CLUSTER_WITH=bookingroot -d bachelorproject/rabbitcluster
    sudo docker run --name bookingserver$i --hostname=bookingserver$i --net-alias=bookingserver  --net=reservierung -e CLUSTERED=true -e CLUSTER_WITH=customermanagementroot -d bachelorproject/rabbitcluster
    sudo docker run --name pricingserver $i --hostname=pricingserver$i --net-alias=pricingserver  --net=reservierung -e CLUSTERED=true -e CLUSTER_WITH=pricingroot -d bachelorproject/rabbitcluster
    sudo docker run --name seatoverviewserver $i --hostname=seatoverviewserver$i --net-alias=seatoverviewserver  --net=reservierung -e CLUSTERED=true -e CLUSTER_WITH=seatoverviewroot -d bachelorproject/rabbitcluster
    sudo docker run --name seatmanagementserver$i --hostname=seatmanagementserver$i --net-alias=seatmanagementserver  --net=reservierung -e CLUSTERED=true -e CLUSTER_WITH=seatmanagementroot -d bachelorproject/rabbitcluster
    ((i = i + 1))
done
