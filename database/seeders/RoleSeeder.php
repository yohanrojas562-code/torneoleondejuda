<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Permisos
        $permissions = [
            // Equipos
            'view_any_team', 'view_team', 'create_team', 'update_team', 'delete_team',
            // Jugadores
            'view_any_player', 'view_player', 'create_player', 'update_player', 'delete_player',
            // Aprobación
            'approve_team', 'approve_player',
            // Torneos
            'view_any_tournament', 'view_tournament', 'create_tournament', 'update_tournament', 'delete_tournament',
            // Categorías
            'view_any_category', 'view_category', 'create_category', 'update_category', 'delete_category',
            // Partidos
            'view_any_match', 'view_match', 'create_match', 'update_match', 'delete_match',
            // Escenarios
            'view_any_venue', 'view_venue', 'create_venue', 'update_venue', 'delete_venue',
            // Clasificación
            'view_any_standing', 'view_standing', 'create_standing', 'update_standing',
            // Configuración
            'view_any_setting', 'update_setting',
            // Usuarios
            'view_any_user', 'view_user', 'create_user', 'update_user', 'delete_user',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Rol Admin - todo
        $admin = Role::firstOrCreate(['name' => 'admin']);
        $admin->syncPermissions($permissions);

        // Rol Árbitro
        $arbitro = Role::firstOrCreate(['name' => 'arbitro']);
        $arbitro->syncPermissions([
            'view_any_match', 'view_match', 'update_match',
            'view_any_team', 'view_team',
            'view_any_player', 'view_player',
        ]);

        // Rol Líder de equipo
        $lider = Role::firstOrCreate(['name' => 'lider_equipo']);
        $lider->syncPermissions([
            'view_any_team', 'view_team', 'create_team', 'update_team',
            'view_any_player', 'view_player', 'create_player', 'update_player',
        ]);

        // Rol Capitán
        $capitan = Role::firstOrCreate(['name' => 'capitan']);
        $capitan->syncPermissions([
            'view_any_team', 'view_team',
            'view_any_player', 'view_player',
        ]);

        // Usuario admin
        $adminUser = User::firstOrCreate(
            ['email' => 'admin@torneoleondejuda.com'],
            [
                'name' => 'Administrador',
                'password' => Hash::make('LeondejudA2025!'),
            ]
        );
        $adminUser->assignRole('admin');
    }
}
