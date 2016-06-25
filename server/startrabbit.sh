if [ -z "$CLUSTERED" ]; then
# Wenn nicht geclustered werden soll, wird einfach ein normaler RabbitMQ Server gestartet
	( sleep 10 ; \

	# Virtuellen Host erstellen
	rabbitmqctl add_vhost ${SERVICE}host ; \

	# Erstellen der Nutzer und Berechtigungen
	rabbitmqctl add_user ${SERVICE} ${SERVICE} ; \
	rabbitmqctl set_user_tags ${SERVICE} ${SERVICE}service ; \
	rabbitmqctl set_permissions -p ${SERVICE}host ${SERVICE} ".*" ".*" ".*" ; \
	rabbitmqctl set_permissions -p ${SERVICE}host guest ".*" ".*" ".*" ; \
	
	#Federation eisntellen
	rabbitmqctl set_parameter -p ${SERVICE}host federation-upstream booking-upstream '{"uri":"amqp://bookingroot:5672","expires":3600000}' ; \
	rabbitmqctl set_parameter -p ${SERVICE}host federation-upstream customermanagement-upstream '{"uri":"amqp://customermanagementroot:5672","expires":3600000}' ; \
	rabbitmqctl set_parameter -p ${SERVICE}host federation-upstream pricing-upstream '{"uri":"amqp://pricingroot:5672","expires":3600000}' ; \
	rabbitmqctl set_parameter -p ${SERVICE}host federation-upstream seatmanagement-upstream '{"uri":"amqp://seatmanagementroot:5672","expires":3600000}' ; \
	rabbitmqctl set_parameter -p ${SERVICE}host federation-upstream seatoverview-upstream '{"uri":"amqp://seatoverviewroot:5672","expires":3600000}' ; \


	rabbitmqctl set_policy -p ${SERVICE}host --apply-to exchanges federate-all ".*" '{"federation-upstream-set":"all"}' ; \

	# Regel für Cluster
	rabbitmqctl set_policy -p ${SERVICE}host booking ".*" '{"ha-mode":"all", "ha-sync-mode":"automatic"}' ; \
	) &

	#Server starten
	/usr/sbin/rabbitmq-server $@

else

	if [ -z "$CLUSTER_WITH" ]; then
		# Wenn geclustered werden soll, aber kein Einstiegspunkt gegeben ist, dann wird ein normaler Server gestartet
		/usr/sbin/rabbitmq-server
	else

		#Ansonsten wird der Server gestartet und gestopped, um den Befehl zum Clustern auszufuehren 
		/usr/sbin/rabbitmq-server -detached
		rabbitmqctl stop_app

		# Festlegung, ob der Knoten auf dem Arbeitsspeicher oder auf die Festplatte schreiben soll
		if [ -z "$RAM_NODE" ]; then
			rabbitmqctl join_cluster rabbit@$CLUSTER_WITH
		else
			rabbitmqctl join_cluster --ram rabbit@$CLUSTER_WITH
		fi

		# Korrektes Starten und Logging des Servers
		rabbitmqctl start_app
		tail -f /var/log/rabbitmq/rabbit\@$HOSTNAME.log
	fi
fi
