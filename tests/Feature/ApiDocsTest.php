<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiDocsTest extends TestCase
{
    public function test_api_docs_interface_is_accessible(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200)
            ->assertSee('E-Commerce REST API Explorer')
            ->assertSee('1-Click Login');
    }

    public function test_docs_alias_route_is_accessible(): void
    {
        $response = $this->get('/docs');

        $response->assertStatus(200)
            ->assertSee('E-Commerce REST API Explorer');
    }
}
