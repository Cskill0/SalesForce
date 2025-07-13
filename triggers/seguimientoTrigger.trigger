trigger seguimientoTrigger on Seguimiento__c (before insert) {
	Set<Id> contactoIds = new Set<Id>();

	for (Seguimiento__c s : Trigger.new) {
		if (s.Contacto_c__c != null && s.Etapa__c == 'Pendiente') {
			contactoIds.add(s.Contacto_c__c);
		}
	}

	if (!contactoIds.isEmpty()) {
		//Seguimientos pendientes
		Map<Id, Integer> pendientesPorContacto = new Map<Id, Integer>();
		for (AggregateResult ar : [
			SELECT Contacto_c__c contactId, COUNT(Id) total
			FROM Seguimiento__c
			WHERE Contacto_c__c IN :contactoIds AND Etapa__c = 'Pendiente'
			GROUP BY Contacto_c__c ]) {
			pendientesPorContacto.put((Id)ar.get('contactId'), (Integer)ar.get('total'));
		}

		for (Seguimiento__c s : Trigger.new) {
			if (s.Contacto_c__c != null && s.Etapa__c == 'Pendiente') {
				Integer existentes = pendientesPorContacto.containsKey(s.Contacto_c__c) ? pendientesPorContacto.get(s.Contacto_c__c) : 0;
				if (existentes >= 5) {
					s.addError('No se puede tener mas de 5 seguimientos con estado "Pendiente" para este contacto');
				}
			}
		}
	}
}