<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;

class RoleSeeder extends Seeder
{
    public function run()
    {
        $roles = [
            ['id' => 1, 'name' => 'Superadmin'],
            ['id' => 2, 'name' => 'Barber Owner'],
            ['id' => 3, 'name' => 'Barber'],
            ['id' => 4, 'name' => 'Client'],
        ];

        foreach ($roles as $role) {
            Role::updateOrCreate(['id' => $role['id']], $role);
        }
    }
}
