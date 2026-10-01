# Level 1 API Reference

> List of API Level 1 requests for the BeSoccer API client.
> Base URL: `https://apiclient.besoccerapps.com/scripts/api/api.php`

---

## 1. Competitions

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns a list of competitions that meet all the initial requirements and that are in the database.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `categories` |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `filter` | No | e.g. `my_leagues` |
| `country` | No | Country filter |

**Cache:** 120 seconds

---

## 2. Competition Status

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Given a championship identifier, a season and a given group, returns the status of a competition matching the given parameters.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `league_status` |
| `id` | Yes | Competition ID (`{{CAT 1}}`) |
| `year` | Yes | Season year (`{{CUR_SEASON}}`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `group` | No | Group identifier |

**Cache:** 600 seconds

---

## 3. Competition Detail

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns the competition data provided by parameter such as year, total matchdays, current matchday, etc.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `data_competitions` |
| `competitions` | Yes | Comma-separated competition IDs (e.g. `1,2`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |

**Cache:** 300 seconds

---

## 4. Competitions by Continent

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Displays all competitions within the continent indicated in the `filter` parameter.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `countries_competitions` |
| `filter` | Yes | Continent code (e.g. `eu`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `lang` | No | Language (`{{LANG}}`) |

**Cache:** 600 seconds

---

## 5. Top Competitions

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns all competitions from any country or continent.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `competitions` |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `country` | No | Country filter |
| `q` | No | Search query |
| `lang` | No | Language (`{{LANG}}`) |
| `filter` | No | Filter type |
| `init` | No | Pagination start |
| `limit` | No | Pagination limit |

**Cache:** 600 seconds

---

## 6. Complete Competition Detail

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Displays basic competition information.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `competition` |
| `id` | Yes | Competition ID (`{{CAT 1}}`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `year` | No | Season year (`{{CUR_SEASON}}`) |

**Cache:** 600 seconds

---

## 7. Classification

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns the ranking of a competition in a given group, day and season.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `tables` |
| `league` | Yes | League ID (`{{CAT 1}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `group` | No | Group identifier |
| `round` | No | Round number |
| `year` | No | Season year |
| `ext` | No | Extended data flag |
| `type` | No | Table type |
| `conference` | No | Conference identifier |

**Cache:** 60 seconds

---

## 8. Detail of Competition Phases

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Displays information on the competitions indicated by parameter.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `competition_info` |
| `competitions` | Yes | Competition ID (`{{CAT 1}}`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `year` | No | Season year (`{{CUR_SEASON}}`) |

**Cache:** 300 seconds

---

## 9. Seasons

**Method:** `GET`
**URL:** `http://apiclient.besoccerapps.com/scripts/api/api.php`

Returns the information of all the seasons of that competition that are in the database.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `seasons` |
| `id` | Yes | Competition ID (`{{CAT 1}}`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `group` | No | Group identifier |
| `year` | No | Season year |

**Cache:** 3600 seconds

---

## 10. Teams

**Method:** `GET`
**URL:** `http://apiclient.besoccerapps.com/scripts/api/api.php`

Returns a list of the teams playing in a tournament in a given season and group.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `teams` |
| `league` | Yes | League ID (`{{CAT 1}}`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |

**Cache:** 60 seconds

---

## 11. Live Matches

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns the number of matches that are in play at the time the call is made.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `live_matches` |
| `format` | No | Response format (`{{FORMAT}}`) |

**Cache:** 120 seconds

---

## 12. Matches of the Day

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns a list of the matches that are played on a given day and that meet all the parameters indicated.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `matchsday` |
| `format` | No | Response format (`{{FORMAT}}`) |
| `date` | No | Target date |
| `top` | No | Top matches flag |
| `country` | No | Country filter |
| `play` | No | Play status filter |
| `init` | No | Pagination start |
| `limit` | No | Pagination limit |
| `teams` | No | Team IDs filter |
| `competitions` | No | Competition IDs filter |
| `lang` | No | Language |
| `matches` | No | Match IDs filter |
| `skip_categories` | No | Categories to skip |

**Cache:** 90 seconds

---

## 13. Matches per Day

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns a list with the matches of that competition that meet each of the requirements indicated in the input parameters.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `matchs` |
| `league` | Yes | League ID (e.g. `1`) |
| `format` | No | Response format (`{{FORMAT}}`) |
| `tz` | No | Timezone (`{{TZ}}`) |
| `group` | No | Group identifier |
| `round` | No | Round number |
| `year` | No | Season year |
| `order` | No | Sort order |
| `twolegged` | No | Two-legged tie flag |
| `extra` | No | Extra data flag |
| `lang` | No | Language + conference |
| `addlink` | No | Add link flag |

**Cache:** 60 seconds

---

## 14. Table of Matches

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns playoff bracket / table of matches for a competition.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `competition_playoffs` |
| `id` | Yes | Competition ID (e.g. `107`) |
| `format` | No | e.g. `json` |
| `lang` | No | Language (e.g. `es`) |
| `year` | No | Season year (e.g. `2023`) |

---

## 15. Modified Timetables

**Method:** `GET`
**URL:** `https://apiclient.besoccerapps.com/scripts/api/api.php`

Returns a list of matches that have been modified as of today's date and time.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `key` | Yes | API key (`{{APIKEY}}`) |
| `req` | Yes | `verify_datetime` |
| `competitions` | Yes | Comma-separated competition IDs |
| `tz` | No | Timezone (`{{TZ}}`) |
| `format` | No | Response format (`{{FORMAT}}`) |

**Cache:** 1800 seconds

---

*Generated from the **Level 1** folder in the Apiclient collection.*