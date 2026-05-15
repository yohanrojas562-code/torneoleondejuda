// Mock data del organigrama del torneo. Reemplazado por
// OrganigramRepository en Step 19. Estructura: Junta Directiva, Coordinación,
// Comisión Técnica, Árbitros, Comité de Disciplina.

class StaffMemberMock {
  const StaffMemberMock({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.photoUrl,
    this.church,
    this.bio,
    this.email,
    this.phone,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String role;
  final String? photoUrl;
  final String? church;
  final String? bio;
  final String? email;
  final String? phone;

  String get fullName => '$firstName $lastName';
}

class OrgSectionMock {
  const OrgSectionMock({
    required this.title,
    required this.iconName,
    required this.members,
  });

  final String title;

  /// Identificador del icono — el widget lo resuelve a `IconData`.
  /// Valores soportados: 'gavel', 'people', 'tactics', 'whistle', 'shield'.
  final String iconName;

  final List<StaffMemberMock> members;
}

abstract final class MockOrganigramData {
  MockOrganigramData._();

  static const president = StaffMemberMock(
    id: 1,
    firstName: 'Pastor Carlos',
    lastName: 'Henao',
    role: 'Presidente del Torneo',
    church: 'Centro de Fe La Salle',
    bio:
        'Lidera el comité organizador del Torneo León de Judá desde su '
        'primera edición. Visión: unir a las iglesias del Centro de Fe a '
        'través del deporte.',
    email: 'presidencia@torneoleondejuda.com',
  );

  static const sections = <OrgSectionMock>[
    OrgSectionMock(
      title: 'Junta Directiva',
      iconName: 'gavel',
      members: [
        StaffMemberMock(
          id: 2,
          firstName: 'Pastor Andrés',
          lastName: 'Velásquez',
          role: 'Vicepresidente',
          church: 'Centro de Fe Sur',
          bio: 'Apoya la dirección general y la articulación entre sedes.',
        ),
        StaffMemberMock(
          id: 3,
          firstName: 'Lina',
          lastName: 'Marín',
          role: 'Secretaria General',
          church: 'Centro de Fe Centro',
          bio: 'Coordina actas, comunicaciones oficiales y agenda del comité.',
          email: 'secretaria@torneoleondejuda.com',
        ),
        StaffMemberMock(
          id: 4,
          firstName: 'Jaime',
          lastName: 'Cárdenas',
          role: 'Tesorero',
          church: 'Centro de Fe Norte',
          bio: 'Administra presupuestos, inscripciones y patrocinios.',
        ),
      ],
    ),
    OrgSectionMock(
      title: 'Coordinación Deportiva',
      iconName: 'people',
      members: [
        StaffMemberMock(
          id: 5,
          firstName: 'Mauricio',
          lastName: 'Restrepo',
          role: 'Coordinador General',
          church: 'Centro de Fe Occidente',
          bio: 'Programa fechas, escenarios y logística general del torneo.',
        ),
        StaffMemberMock(
          id: 6,
          firstName: 'Diana',
          lastName: 'Ospina',
          role: 'Coordinadora Logística',
          church: 'Centro de Fe Aranjuez',
          bio: 'Gestiona escenarios, balones, uniformes y materiales.',
        ),
      ],
    ),
    OrgSectionMock(
      title: 'Comisión Técnica',
      iconName: 'tactics',
      members: [
        StaffMemberMock(
          id: 7,
          firstName: 'Ricardo',
          lastName: 'Mejía',
          role: 'Director Técnico',
          church: 'Centro de Fe Robledo',
          bio: 'Define formato de competencia, reglamento y modalidades.',
        ),
        StaffMemberMock(
          id: 8,
          firstName: 'Felipe',
          lastName: 'Cano',
          role: 'Analista Deportivo',
          church: 'Centro de Fe La Salle',
          bio: 'Revisa estadísticas y verifica resultados de cada jornada.',
        ),
        StaffMemberMock(
          id: 9,
          firstName: 'Esteban',
          lastName: 'Quintero',
          role: 'Asesor Técnico',
          church: 'Centro de Fe Bocagrande',
        ),
      ],
    ),
    OrgSectionMock(
      title: 'Comité de Arbitraje',
      iconName: 'whistle',
      members: [
        StaffMemberMock(
          id: 10,
          firstName: 'Hernán',
          lastName: 'Salazar',
          role: 'Árbitro Principal',
          bio: 'Coordina al cuerpo arbitral y los árbitros designados.',
        ),
        StaffMemberMock(
          id: 11,
          firstName: 'Luis',
          lastName: 'Bedoya',
          role: 'Árbitro',
        ),
        StaffMemberMock(
          id: 12,
          firstName: 'Javier',
          lastName: 'Patiño',
          role: 'Árbitro',
        ),
        StaffMemberMock(
          id: 13,
          firstName: 'Camilo',
          lastName: 'Vargas',
          role: 'Árbitro Asistente',
        ),
      ],
    ),
    OrgSectionMock(
      title: 'Comité de Disciplina',
      iconName: 'shield',
      members: [
        StaffMemberMock(
          id: 14,
          firstName: 'Pastor Hugo',
          lastName: 'Aristizábal',
          role: 'Presidente',
          church: 'Centro de Fe La Salle',
          bio: 'Revisa sanciones, apelaciones y conducta de jugadores.',
        ),
        StaffMemberMock(
          id: 15,
          firstName: 'Sandra',
          lastName: 'Galindo',
          role: 'Miembro',
          church: 'Centro de Fe Olaya',
        ),
        StaffMemberMock(
          id: 16,
          firstName: 'Óscar',
          lastName: 'Mendoza',
          role: 'Miembro',
          church: 'Centro de Fe Oriente',
        ),
      ],
    ),
  ];
}
