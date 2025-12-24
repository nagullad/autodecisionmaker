var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Redirect HTTP to HTTPS
app.UseHttpsRedirection();

// Serve static files from wwwroot (React SPA). Default file is index.html
app.UseDefaultFiles();
app.UseStaticFiles();

// Add routing middleware
app.UseRouting();

app.UseAuthorization();

// Map API controllers first so API routes are handled by the backend
app.MapControllers();

// Fallback to wwwroot/index.html for client-side routes handled by the SPA
app.MapFallbackToFile("index.html");

app.Run();
