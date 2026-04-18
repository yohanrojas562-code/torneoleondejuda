<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Sub-12, Sub-15, Libre, etc.
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->integer('min_age')->nullable();
            $table->integer('max_age')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('tournaments', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('logo')->nullable();
            $table->string('banner')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->string('venue')->nullable();
            $table->text('rules')->nullable();
            $table->enum('status', ['draft', 'registration', 'in_progress', 'finished', 'cancelled'])->default('draft');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('seasons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tournament_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // "Temporada 1 - 2026"
            $table->string('slug')->unique();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->enum('status', ['draft', 'registration', 'group_stage', 'knockout', 'finished'])->default('draft');
            $table->json('settings')->nullable(); // points per win, draw, etc.
            $table->timestamps();
        });

        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('short_name')->nullable();
            $table->string('logo')->nullable();
            $table->string('primary_color')->nullable();
            $table->string('secondary_color')->nullable();
            $table->foreignId('leader_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('captain_id')->nullable()->constrained('users')->nullOnDelete();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('season_team', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->cascadeOnDelete();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->string('group')->nullable(); // A, B, C, D
            $table->enum('status', ['registered', 'active', 'eliminated', 'disqualified'])->default('registered');
            $table->timestamps();
            $table->unique(['season_id', 'team_id']);
        });

        Schema::create('players', function (Blueprint $table) {
            $table->id();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('document_number')->nullable();
            $table->date('birth_date')->nullable();
            $table->string('photo')->nullable();
            $table->integer('jersey_number')->nullable();
            $table->string('position')->nullable(); // portero, defensa, mediocampista, delantero
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('groups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Grupo A, Grupo B
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        Schema::create('group_team', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->unique(['group_id', 'team_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('group_team');
        Schema::dropIfExists('groups');
        Schema::dropIfExists('players');
        Schema::dropIfExists('season_team');
        Schema::dropIfExists('teams');
        Schema::dropIfExists('seasons');
        Schema::dropIfExists('tournaments');
        Schema::dropIfExists('categories');
    }
};
