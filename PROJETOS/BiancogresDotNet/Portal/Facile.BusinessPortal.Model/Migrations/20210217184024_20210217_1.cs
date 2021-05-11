using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210217_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FIDCAtivo",
                table: "ContaBancaria",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<long>(
                name: "FIDCID",
                table: "ContaBancaria",
                nullable: true,
                defaultValue: 0L);

            migrationBuilder.CreateTable(
                name: "FIDC",
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
                    OID = table.Column<Guid>(nullable: false),
                    CPFCNPJ = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: false),
                    CEP = table.Column<string>(nullable: false),
                    Logradouro = table.Column<string>(nullable: true),
                    Numero = table.Column<string>(nullable: true),
                    Complemento = table.Column<string>(nullable: true),
                    Bairro = table.Column<string>(nullable: true),
                    UF = table.Column<string>(nullable: true),
                    Cidade = table.Column<string>(nullable: true),
                    Observacoes = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FIDC", x => x.ID);
                    table.ForeignKey(
                        name: "FK_FIDC_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_FIDC_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ContaBancaria_FIDCID",
                table: "ContaBancaria",
                column: "FIDCID");

            migrationBuilder.CreateIndex(
                name: "IX_FIDC_EmpresaID",
                table: "FIDC",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_FIDC_UnidadeID",
                table: "FIDC",
                column: "UnidadeID");

            migrationBuilder.AddForeignKey(
                name: "FK_ContaBancaria_FIDC_FIDCID",
                table: "ContaBancaria",
                column: "FIDCID",
                principalTable: "FIDC",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ContaBancaria_FIDC_FIDCID",
                table: "ContaBancaria");

            migrationBuilder.DropTable(
                name: "FIDC");

            migrationBuilder.DropIndex(
                name: "IX_ContaBancaria_FIDCID",
                table: "ContaBancaria");

            migrationBuilder.DropColumn(
                name: "FIDCAtivo",
                table: "ContaBancaria");

            migrationBuilder.DropColumn(
                name: "FIDCID",
                table: "ContaBancaria");
        }
    }
}
