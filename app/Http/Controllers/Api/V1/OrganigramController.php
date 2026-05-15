<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\TeamMemberResource;
use App\Models\TeamMember;

class OrganigramController extends Controller
{
    public function __invoke()
    {
        $members = TeamMember::where('is_active', true)
            ->orderBy('order')
            ->orderBy('name')
            ->get();

        return response()->json([
            'members' => TeamMemberResource::collection($members),
            'role_labels' => TeamMember::roleLabels(),
        ]);
    }
}
