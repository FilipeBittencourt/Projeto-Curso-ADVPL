﻿using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201211_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ContratoID",
                table: "SolicitacaoServico",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Contrato",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    Codigo = table.Column<string>(nullable: true),
                    Descricao = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Contrato", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Contrato_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Contrato_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_ContratoID",
                table: "SolicitacaoServico",
                column: "ContratoID");

            migrationBuilder.CreateIndex(
                name: "IX_Contrato_EmpresaID",
                table: "Contrato",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Contrato_UnidadeID",
                table: "Contrato",
                column: "UnidadeID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_Contrato_ContratoID",
                table: "SolicitacaoServico",
                column: "ContratoID",
                principalTable: "Contrato",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_Contrato_ContratoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropTable(
                name: "Contrato");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_ContratoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "ContratoID",
                table: "SolicitacaoServico");
        }
    }
}
