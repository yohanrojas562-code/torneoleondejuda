<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pqrs', function (Blueprint $table) {
            $table->id();
            $table->string('case_number')->unique();
            $table->enum('type', ['peticion', 'queja', 'reclamo', 'sugerencia', 'apelacion', 'felicitacion']);
            $table->string('subject');
            $table->text('description');
            $table->string('submitter_name');
            $table->string('submitter_email');
            $table->string('submitter_phone')->nullable();
            $table->foreignId('submitter_team_id')->nullable()->constrained('teams')->nullOnDelete();
            $table->string('submitter_role');
            $table->enum('status', ['received', 'in_review', 'in_progress', 'awaiting_response', 'resolved', 'closed', 'rejected'])->default('received');
            $table->enum('priority', ['low', 'medium', 'high', 'urgent'])->default('medium');
            $table->foreignId('assigned_to')->nullable()->constrained('users')->nullOnDelete();
            $table->text('internal_notes')->nullable();
            $table->text('resolution')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('status');
            $table->index('type');
            $table->index('priority');
        });

        Schema::create('pqrs_responses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pqrs_id')->constrained('pqrs')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('type', ['note', 'status_change', 'public_response', 'action_taken', 'assignment']);
            $table->text('content');
            $table->string('previous_status')->nullable();
            $table->string('new_status')->nullable();
            $table->boolean('is_visible_to_submitter')->default(false);
            $table->timestamps();

            $table->index('pqrs_id');
        });

        Schema::create('pqrs_attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pqrs_id')->constrained('pqrs')->cascadeOnDelete();
            $table->foreignId('response_id')->nullable()->constrained('pqrs_responses')->cascadeOnDelete();
            $table->string('file_path');
            $table->string('file_name');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size');
            $table->timestamps();

            $table->index('pqrs_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pqrs_attachments');
        Schema::dropIfExists('pqrs_responses');
        Schema::dropIfExists('pqrs');
    }
};
