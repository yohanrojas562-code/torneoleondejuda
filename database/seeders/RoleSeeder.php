<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $roles = ['admin', 'arbitro', 'lider_equipo', 'capitan'];

        foreach ($roles as $role) {
            Role::firstOrCreate(['name' => $role]);
        }

        $admin = User::firstOrCreate(
            ['email' => 'admin@torneoleondejuda.com'],
            [
                'name' => 'Administrador',
                'password' => Hash::make('LeondejudA2025!'),
            ]
        );

        $admin->assignRole('admin');
    }
}
